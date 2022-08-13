CREATE PROCEDURE sp_ProductPathCreate
AS

/*

Author: Muhammet Furkan G�KDEM�R (MUFUGO)
Created Date: 22.03.2022 - 16:00 (04:00 PM)
Last Update Date: 13.08.2022 - 10:45 (AM)

Description;

Tablolarda kay�tl� olan �r�n kodlar�n�n dosya konumunu FileList tablosuna kay�t atan prosed�r, genellikle bir kez �al��t�r�l�r.
Not: �lk kay�tta her zaman FileExist s�tununa kay�t 0 olarak g�nderilir. Yani dosya yokmu� gibi kay�t atar.

The procedure, which records the file location of Product IDs that are registered in tables to the FileList table, is typically run once. 
Note: On the first record, the record is always sent as 0 in the FileExist column. So it assigns the record as if the file did not exist.

Sweet little rebellion;

Bu istek yakla��k olarak aral�ks�z 10 saatimi alm��t�r, �u kadarc�k kod 10 saatmi diye sormay�n, bu kod bu hale getirilene kadar can�m ��kt�.

@file_name -- De�i�ken olan file name // EN: @file_name -- File name that is variable
file_name -- FileList tablosunun i�erisinde yer alan file_name s�tunu // EN: file_name column in the FileList table
filename -- Ge�i�i olarak tan�mlama yapt���m�z bir alan RowNumber i�in yap�ld� // EN: filename -- A field that we defined as temporary was made for RowNumber
RowNumber(filename) -- Birden fazla veri geldi�i i�in tek tek @file_name de�i�kenine s�ras�yla FileList tablosunda yer alan file_name s�tununu atamas� amac�yla yap�ld�.
EN: RowNumber(filename) -- Because there is more than one data coming in, it was made to assign the @file_name column in the FileList table, respectively, to the individual file_name variable.
*/

-- Tan�mlamalar Yap�ld�
SET NOCOUNT ON
DECLARE @Counter INT , @Count INT, @FileCheck INT
SELECT @Counter = 1 , @Count = COUNT(ItemCode) from dbo.prItemVariant WHERE ItemTypeCode = 1 AND ItemCode NOT IN ('COMO','CV','DMS','DV','HOPI','PARO','RESIDUAL')
DECLARE @ItemCode NVARCHAR(MAX), @ColorCode NVARCHAR(MAX) -- kontrol ettikten sonra �r�nleri buraya at�yor s�rayla
-- FileList tablosundaki (tan�mlamalar k�sm�nda @Count olarak tan�mlad���m�z) de�er kontrol edilerek while d�ng�s� ba�lat�ld�
WHILE(@Counter <= @Count)
BEGIN
-- dosya ad� her sat�rda farkl� olmas� ve tek bir sat�r d�nd�rmesi i�in i�lem yap�ld� ge�ici bir tablo olu�turmak gibi bir i�lem
WITH filename AS  
(  
	-- bu select tablodaki t�m sat�rlar� ORDER BY file_name asc olacak �ekilde ayarlad� ve onlara s�ra numaras� atad�
    SELECT ItemCode, ColorCode   , ROW_NUMBER() OVER (ORDER BY ItemCode) AS RowNumber  
    FROM dbo.prItemVariant WHERE ItemTypeCode = 1 AND ItemCode NOT IN ('COMO','CV','DMS','DV','HOPI','PARO','RESIDUAL')
)  

/* 
Daha sonra @file_name de�i�kenine veri tan�mlamas� yap�ld�, tan�mlama yap�l�rken filename alan�ndan gelen de�erler �ekildi 
ve filtre olarak Sat�r Say�s� (RowNumber), while d�ng�s�ndeki s�ra say�s�na (Counter) e�itlendi 

*/

SELECT @ItemCode = ItemCode, @ColorCode = ColorCode  
FROM filename  
WHERE RowNumber = @Counter

-- D�ng�de kald���ndan �t�r� temp datay� silmiyordu normalde en �stteydi ancak d�ng�de tek de�er d�nd�rebilmesi i�in temp datay� olu�turan kodu d�ng�n�n i�ine ald�m



SELECT @FileCheck = COUNT(*) FROM dbo.FileList WHERE ItemCode = @ItemCode AND ColorCode = @ColorCode

	IF @FileCheck = 0
	BEGIN
	INSERT INTO dbo.FileList (file_name,file_exist,ItemCode,ColorCode) VALUES ((
	(SELECT FolderPath FROM dfGlobalFolder WITH(NOLOCK) WHERE FolderCode = 'ProductPhotoPath' AND GlobalDefaultCode = 1) + @ItemCode + '\ColorPhotos\' + @ItemCode + '_'+ @ColorCode + '.jpg')
	,0,@ItemCode,@ColorCode)
	
	END
	SELECT @Counter += 1
END
