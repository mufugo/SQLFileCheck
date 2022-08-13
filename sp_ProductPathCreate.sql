CREATE PROCEDURE sp_ProductPathCreate
AS

/*

Author: Muhammet Furkan GÖKDEMÝR (MUFUGO)
Created Date: 22.03.2022 - 16:00 (04:00 PM)
Last Update Date: 13.08.2022 - 10:45 (AM)

Description;

Tablolarda kayýtlý olan Ürün kodlarýnýn dosya konumunu FileList tablosuna kayýt atan prosedür, genellikle bir kez çalýþtýrýlýr.
Not: Ýlk kayýtta her zaman FileExist sütununa kayýt 0 olarak gönderilir. Yani dosya yokmuþ gibi kayýt atar.

The procedure, which records the file location of Product IDs that are registered in tables to the FileList table, is typically run once. 
Note: On the first record, the record is always sent as 0 in the FileExist column. So it assigns the record as if the file did not exist.

Sweet little rebellion;

Bu istek yaklaþýk olarak aralýksýz 10 saatimi almýþtýr, þu kadarcýk kod 10 saatmi diye sormayýn, bu kod bu hale getirilene kadar caným çýktý.

@file_name -- Deðiþken olan file name // EN: @file_name -- File name that is variable
file_name -- FileList tablosunun içerisinde yer alan file_name sütunu // EN: file_name column in the FileList table
filename -- Geçiçi olarak tanýmlama yaptýðýmýz bir alan RowNumber için yapýldý // EN: filename -- A field that we defined as temporary was made for RowNumber
RowNumber(filename) -- Birden fazla veri geldiði için tek tek @file_name deðiþkenine sýrasýyla FileList tablosunda yer alan file_name sütununu atamasý amacýyla yapýldý.
EN: RowNumber(filename) -- Because there is more than one data coming in, it was made to assign the @file_name column in the FileList table, respectively, to the individual file_name variable.
*/

-- Tanýmlamalar Yapýldý
SET NOCOUNT ON
DECLARE @Counter INT , @Count INT, @FileCheck INT
SELECT @Counter = 1 , @Count = COUNT(ItemCode) from dbo.prItemVariant WHERE ItemTypeCode = 1 AND ItemCode NOT IN ('COMO','CV','DMS','DV','HOPI','PARO','RESIDUAL')
DECLARE @ItemCode NVARCHAR(MAX), @ColorCode NVARCHAR(MAX) -- kontrol ettikten sonra ürünleri buraya atýyor sýrayla
-- FileList tablosundaki (tanýmlamalar kýsmýnda @Count olarak tanýmladýðýmýz) deðer kontrol edilerek while döngüsü baþlatýldý
WHILE(@Counter <= @Count)
BEGIN
-- dosya adý her satýrda farklý olmasý ve tek bir satýr döndürmesi için iþlem yapýldý geçici bir tablo oluþturmak gibi bir iþlem
WITH filename AS  
(  
	-- bu select tablodaki tüm satýrlarý ORDER BY file_name asc olacak þekilde ayarladý ve onlara sýra numarasý atadý
    SELECT ItemCode, ColorCode   , ROW_NUMBER() OVER (ORDER BY ItemCode) AS RowNumber  
    FROM dbo.prItemVariant WHERE ItemTypeCode = 1 AND ItemCode NOT IN ('COMO','CV','DMS','DV','HOPI','PARO','RESIDUAL')
)  

/* 
Daha sonra @file_name deðiþkenine veri tanýmlamasý yapýldý, tanýmlama yapýlýrken filename alanýndan gelen deðerler çekildi 
ve filtre olarak Satýr Sayýsý (RowNumber), while döngüsündeki sýra sayýsýna (Counter) eþitlendi 

*/

SELECT @ItemCode = ItemCode, @ColorCode = ColorCode  
FROM filename  
WHERE RowNumber = @Counter

-- Döngüde kaldýðýndan ötürü temp datayý silmiyordu normalde en üstteydi ancak döngüde tek deðer döndürebilmesi için temp datayý oluþturan kodu döngünün içine aldým



SELECT @FileCheck = COUNT(*) FROM dbo.FileList WHERE ItemCode = @ItemCode AND ColorCode = @ColorCode

	IF @FileCheck = 0
	BEGIN
	INSERT INTO dbo.FileList (file_name,file_exist,ItemCode,ColorCode) VALUES ((
	(SELECT FolderPath FROM dfGlobalFolder WITH(NOLOCK) WHERE FolderCode = 'ProductPhotoPath' AND GlobalDefaultCode = 1) + @ItemCode + '\ColorPhotos\' + @ItemCode + '_'+ @ColorCode + '.jpg')
	,0,@ItemCode,@ColorCode)
	
	END
	SELECT @Counter += 1
END
