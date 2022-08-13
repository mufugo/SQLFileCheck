CREATE PROCEDURE [dbo].[sp_ProductPathCheck]
AS
/*

Author: Muhammet Furkan GÖKDEMİR (MUFUGO)
Created Date: 22.03.2022 - 16:00 (04:00 PM)
Last Update Date: 13.08.2022 - 10:45 (AM)

Description;

Var olan dosyanın kontrolü yapan prosedür.
The procedure that checks an existing file.
 
Sweet little rebellion;

Bu istek yaklaşık olarak aralıksız 10 saatimi almıştır, şu kadarcık kod 10 saatmi diye sormayın, bu kod bu hale getirilene kadar canım çıktı.

@file_name -- Değişken olan file name // EN: @file_name -- File name that is variable
file_name -- FileList tablosunun içerisinde yer alan file_name sütunu // EN: file_name column in the FileList table
filename -- Geçiçi olarak tanımlama yaptığımız bir alan RowNumber için yapıldı // EN: filename -- A field that we defined as temporary was made for RowNumber
RowNumber(filename) -- Birden fazla veri geldiği için tek tek @file_name değişkenine sırasıyla FileList tablosunda yer alan file_name sütununu ataması amacıyla yapıldı.
EN: RowNumber(filename) -- Because there is more than one data coming in, it was made to assign the @file_name column in the FileList table, respectively, to the individual file_name variable.
*/

-- Tanımlamalar Yapıldı
-- Definitions Made
SET NOCOUNT ON
DECLARE @Counter INT , @Count INT
SELECT @Counter = 1 , @Count = COUNT(file_name) from dbo.FileList
DECLARE @file_name NVARCHAR(1000)

-- FileList tablosundaki (tanımlamalar kısmında @Count olarak tanımladığımız) değer kontrol edilerek while döngüsü başlatıldı
-- The while loop is started by checking the value in the FileList table (which we define as @Count in the definitions section)
WHILE(@Counter <= @Count)
BEGIN
-- dosya adı her satırda farklı olması ve tek bir satır döndürmesi için işlem yapıldı geçici bir tablo oluşturmak gibi bir işlem
-- the file name is different in each row and the operation was done to return a single row, such as creating a temporary table
WITH filename AS  
(  
	-- bu select tablodaki tüm satırları ORDER BY file_name asc olacak şekilde ayarladı ve onlara sıra numarası atadı
	-- this select set all rows in the table to be ASC file_name ORDER BY and assigned them sequence numbers
	SELECT file_name   , ROW_NUMBER() OVER (ORDER BY file_name) AS RowNumber  
    FROM FileList
)  

/* 
Daha sonra @file_name değişkenine veri tanımlaması yapıldı, tanımlama yapılırken filename alanından gelen değerler çekildi 
ve filtre olarak Satır Sayısı (RowNumber), while döngüsündeki sıra sayısına (Counter) eşitlendi 

Then, data definition was made to the @file_name variable, and the values from the filename field were pulled
while the identification was being made. and RowNumber as a filter, synchronized to the number of rows in the while loop (Counter)

*/

SELECT @file_name = file_name  
FROM filename  
WHERE RowNumber = @Counter

DECLARE @cmd NVARCHAR(1000)
-- Ağda olan klasörde sorgulama yapıyor, aşağıda da işlem bittikten sonra bağlantıyı kapatıyor.
-- It queries the folder on the network, and closes the connection after the process is finished below.
SELECT @cmd = 'net use Z: \\MYSERVERNAME\myfiles /user:\Administrator mypassword'
exec xp_cmdShell @cmd
if OBJECT_ID('tempdb..#TempFileResult') is not null
    drop table #TempFileResult
create table #TempFileResult (File_exists int, File_directory int,parent_dir int)

-- Temp dataya @file_name değişkeninde var olan (döngü kaçıncı sıradaysa o dosya adını alır) dosyanın fiziksel olarak var olup olmadığını kontrol ettirip sonucu insert ettim
-- I checked whether the file that existed in the temp dataya @file_name variable (which takes the file name in whatever order the loop is) physically exists and inserted the result
		INSERT INTO #TempFileResult EXEC Master.dbo.xp_fileexist @file_name

		-- Daha sonra FileList tabloma çıkan sonucu update ettim yani dosya varsa 1 yoksa 0 atacak çünkü insertte de onu attım temp dataya
		-- Then I updated the result to my FileList table, so if there is a file, it will throw 1 or 0 because I threw it in the insert temp dataya
		UPDATE  dbo.FileList
		SET     file_exist = (select File_exists from #TempFileResult)
		WHERE   file_name = @file_name

exec xp_cmdShell 'net use Z: /delete'
		-- Döngünün loopa girmesini engellemek için counterı her işlem sonu 1 arttırdım
		-- I increased the counter by 1 at each trade break to prevent the loop from entering the loop
	SELECT @Counter += 1
END

GO