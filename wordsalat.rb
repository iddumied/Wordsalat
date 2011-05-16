require 'timeout'
class Wordsallad
  def initialize(row = 20, columns = 40, filler = "0", datei = "ausgabe", surce="surce.txt")
    @datei_name = datei
    @html_head_higlighted = "
                  <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
                  <html xmlns='http://www.w3.org/1999/xhtml'>
                    <head>
                      <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
                      <title>Wordslat</title>
                      <style type='text/css'><!--
                      div{
                              border-left:1px solid #000;
                              border-top:1px solid #000;
                              width:19px;
                              height:19px;
                              float:left;
                              text-align:center;
                      }
                      .mode0{
                              background-color:#60F;
                      }
                      .mode1{
                              background-color:#6F0;
                      }
                      .mode2{
                              background-color:#FF0;
                      }
                      .mode5{
                              background-color:#F00;
                      }
                      //--></style>
                    </head>
                    <body>
                      <center>
                        <div style='width:auto; height:auto; border:1px solid #000; padding:2px; magrin:7px;' class='mode0'>Senkrecht</div>
                        <div style='width:auto; height:auto; border:1px solid #000; padding:2px; magrin:7px;' class='mode1'>Wagerecht</div>
                        <div style='width:auto; height:auto; border:1px solid #000; padding:2px; magrin:7px;' class='mode2'>Diagonal</div>
                        <div style='width:auto; height:auto; border:1px solid #000; padding:2px; magrin:7px;' class='mode5'>&Uuml;berlapende Buchstaben</div>
                        <p>&nbsp;</p>

    
    "
    @html_head_finish = "
                  <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
                  <html xmlns='http://www.w3.org/1999/xhtml'>
                    <head>
                      <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
                      <title>Wordslat</title>
                      <style type='text/css'><!--
                      div{
                              border-left:1px solid #000;
                              border-top:1px solid #000;
                              width:19px;
                              height:19px;
                              float:left;
                              text-align:center;
                      }
                      //--></style>
                    </head>
                    <body>"
    @html_ramen ="<div style='width:#{20*columns}px; height:#{20*row}px; float:left; border-top:0px; border-left:0px; border-bottom:1px solid #000; border-right:1px solid #000; overflow:hidden;'>"
    @html_food = "</center>
                  </body>
                  </html>"
    @row = row
    @columns = columns
    @filler = filler
    @field = Array.new(@row) {Array.new(@columns, @filler)}
    @datei = File.new("#{datei}.txt", "w")
    convert_file(surce)
    @max_word_length = get_max_word_length
    @alphabet ="ABCDEFGHIJKLMNOPQRSTUVWYZ"
    for i in (0..@words.length - 1) do
      @words[i] = @words[i].upcase
    end
    caption
  end
  

  
  def make_best(time, resolution = 1)
    @columns = @words.length
    if @columns < 40 then @columns = 40 end
    @row = (@columns*resolution).to_i
    @field = Array.new(@row) {Array.new(@columns, @filler)}
    temp_field = @field
    begin
      Timeout::timeout(time) {
        i = 1
        loop do
          insert_words
          temp_field = @field
          @columns -= 1
          @row = (@columns*resolution).to_i
          @field = Array.new(@row) {Array.new(@columns, @filler)}
          puts "#{i}. durchlauf"
          i += 1
          if @max_word_length > @columns
            raise "to big words are used" 
          end
        end
      }
    rescue
      @columns += 1
      @row += 1
      puts "Woertersallat berechnet mit"
      puts "#{@row} Zeilen, #{@columns} Spalten"
      puts "in der Zeit: #{time}, mit #{@words.length} Woertern"
      @field = temp_field
      @html_ramen ="<div style='width:#{20*@columns}px; height:#{20*@row}px; float:left; border-top:0px; border-left:0px; border-bottom:1px solid #000; border-right:1px solid #000; overflow:hidden;'>"
    end
  end
  
  def get_max_word_length
    max_word_length = 0
    @words.each do |word|
      if max_word_length < word.length then
        max_word_length = word.length
      end
    end
    return max_word_length
  end
  def convert_file(file)
    @words = Array.new
    datei = File.open(file, "r")
    datei.each_line do |line|
      @words << line.chop
    end
    datei.close
  end
  
  
  def clear_field
    for i in (0..@row-1) do
      for j in (0..@columns-1) do
          @field[i][j] = @filler
      end
    end    
  end
  
  def insert_words(time = 0.001)
    
    begin
      #puts "start"
      clear_field
      breaked = false
      
      @words.each do |word|
        begin
          Timeout::timeout(time) {
            insert_word(word, Random.rand(3))
          }
        rescue
          begin
            Timeout::timeout(time) {
              insert_word(word, 0)
            }
          rescue
            begin
              Timeout::timeout(time) {
                insert_word(word, 1)
              }
            rescue
              begin
                Timeout::timeout(time) {
                  insert_word(word, 2)
                }
              rescue
                #geht nicht mehr weiter von vorne beginnen
                #puts "break"
                breaked = true
                break
              end
            end
          end
        end
      end 
      
    end while breaked == true
  end
  
  def insert_word(word, mode = 0)
    case mode 
      when 0 then
        loop do
          w_row = Random.rand(@row)
          start_position = Random.rand(@columns - word.length)
          empty = true
          if @field[w_row][start_position - 1] == @filler or start_position == 0 then
            for i in (0..word.length - 1) do
              unless @field[w_row][start_position + i] == @filler or @field[w_row][start_position + i] == word[i] then
                  empty = false
              end
            end
          else
            empty = false # abstand zu voherigem wort nicht eigehalten(wort muss entweder in anderm wort sein, aber nicht direckt angrenzedn)
          end

          if empty == true then
            for i in (0..word.length - 1) do
              if @field[w_row][start_position + i] == @filler then
                @field[w_row][start_position + i] = [word[i], mode]
              else
                @field[w_row][start_position + i] = [word[i], 5]
              end
            end
            break
          end
        end
        
      when 1 then
        loop do
          w_columns = Random.rand(@columns)
          start_position = Random.rand(@row - word.length)
          empty = true
          if @field[start_position - 1][w_columns] == @filler or start_position == 0 then
            for i in (0..word.length - 1) do
              unless @field[start_position + i][w_columns] == @filler or @field[start_position + i][w_columns] == word[i] then
                empty = false
              end          
            end
          else
            empty = false
          end

          if empty == true then
            for i in (0..word.length - 1) do
              if @field[start_position + i][w_columns] == @filler then
                @field[start_position + i][w_columns] = [word[i], mode]
              else
                @field[start_position + i][w_columns] = [word[i], 5]
              end
            end
            break
          end
        end
        
      when 2 then
        loop do
          start_position_row = Random.rand(@row - word.length)
          start_position_columns = Random.rand(@columns - word.length)
          empty = true
          if @field[start_position_row - 1][start_position_columns - 1] == @filler or start_position_row == 0 or start_position_columns == 0 then
            for i in (0..word.length - 1) do
              unless @field[start_position_row + i][start_position_columns + i] == @filler or @field[start_position_row + i][start_position_columns + i] == word[i] then
                empty = false
              end
            end
          else
            empty = false
          end

          if empty == true then
            for i in (0..word.length - 1) do
              if @field[start_position_row + i][start_position_columns + i] == @filler then
                @field[start_position_row + i][start_position_columns + i] = [word[i], mode]
              else
                @field[start_position_row + i][start_position_columns + i] = [word[i], 5]
              end
            end
            break
          end
        end
        
    end
    
  end
  
  def print_field_table
    @columns.times do @datei.print " -" end
    @datei.puts ""
    @field.each  do |row|
      row.each do |element|
        @datei.print "|"
        @datei.print element[0]
      end
      @datei.print "|"
      @datei.puts ""
      @columns.times do @datei.print " -" end
      @datei.puts ""
    end
    @datei.puts "\n"
  end
  
  def print_field_leer
    @field.each  do |row|
      row.each do |element|
        @datei.print element[0]
      end
      @datei.puts ""
    end
    @datei.puts "\n"
  end
  
  def print_field_html
    datei_html = File.new("#{@datei_name}_solution.html", "w")
    datei_html.puts @html_head_higlighted
    datei_html.puts @html_ramen
    @field.each  do |row|
      row.each do |element|
        datei_html.print "<div class=\"mode#{element[1]}\">#{element[0]}</div>"
      end
      datei_html.puts ""
    end
    datei_html.puts "</div>\n"
    datei_html.puts @html_food
    datei_html.close
    
    datei_html = File.new("#{@datei_name}.html", "w")
    datei_html.puts @html_head_finish
    datei_html.puts @html_ramen
    @field.each  do |row|
      row.each do |element|
        datei_html.print "<div class=\"mode#{element[1]}\">#{element[0]}</div>"
      end
      datei_html.puts ""
    end
    datei_html.puts "</div>\n"
    datei_html.puts @html_food
    datei_html.close  
  end
  
  def insert_random_letters  
    for i in (0..@row-1) do
      for j in (0..@columns-1) do
        if @field[i][j] == @filler then
          rand = Random.rand(@alphabet.length-1)
          @field[i][j] = [@alphabet[rand], -1]
        end
      end
    end
  end

  def destruct
    @datei.close
  end
  

  
  
  
end


  def caption
    system("cls")
    puts "******************************"
    puts "*** Wordsallat - Generator ***"
    puts "******************************\n\n"
  end
  
  def automatic_modus
    puts "Automatikmodus aktiviert!"
    if File.exists?("words.txt") == true then
      sallad = Wordsallad.new(0,0, " ", "wordsallad", "words.txt")
      sallad.make_best(60)
      sallad.insert_random_letters
      sallad.print_field_html
      sallad.destruct
      caption
      puts "Folgende Dateien wurden erfolgreich erstellt:\nwordsallad_solution.html, wordsallad.html\n\n\n\n"
      system("pause")
      exit!
    else
      puts "words.txt existiert nicht im ausfuehrenden Ordner"
      puts "programm wird beendet.."
      system("pause")
      exit!
    end
  end

loop do
  caption
  print "Welcher Modus soll verwendet werden?\n(a)utomatisch / (m)anuell\nEingabe: "
  if gets.to_s.chop! == "a" then
    caption
    automatic_modus
  end
end

#print "Zeilen: "
#zeilen = gets.to_i
#print "Spalten: "
#spalten = gets.to_i
sallad = Wordsallad.new(30,40, " ", "ausgabe", "password.lst")
sallad.make_best(600)
#sallad.insert_words(0.1)
sallad.print_field_leer
sallad.print_field_table
sallad.print_field_html
sallad.insert_random_letters

sallad.print_field_leer
sallad.print_field_table
sallad.print_field_html
sallad.destruct
