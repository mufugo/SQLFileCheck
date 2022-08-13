CREATE TRIGGER [dbo].[tr_CreatePhotoPathforVariant]
ON [dbo].[prItemVariant] AFTER INSERT
AS

/*


Author: Muhammet Furkan GÖKDEMÝR (MUFUGO)
Created Date: 22.03.2022 - 16:00 (04:00 PM)
Last Update Date: 13.08.2022 - 11:00 (AM)

Description;

Trigger ile eðer ürün tablosuna yeni bir renk eklenirse ilgili rengin dosya konumunu FileList tablosuna kayýt atýyor.
With Trigger, if a new color is added to the product table, it records the file location of the relevant color in the FileList table.

*/

DECLARE @ItemCode NVARCHAR(MAX)
DECLARE @ColorCode NVARCHAR(MAX)
SELECT @ItemCode = ItemCode, @ColorCode = ColorCode FROM Inserted

IF (SELECT @ItemCode) IS NOT NULL
	IF (SELECT COUNT(*) FROM FileList WHERE ItemCode = @ItemCode AND ColorCode = @ColorCode ) > 0
		DELETE FileList WHERE ItemCode = @ItemCode AND ColorCode = @ColorCode
INSERT INTO FileList (file_name,file_exist,ItemCode,ColorCode) VALUES ((
(SELECT FolderPath FROM dfGlobalFolder WITH(NOLOCK) WHERE FolderCode = 'ProductPhotoPath' AND GlobalDefaultCode = 1) + @ItemCode + '\ColorPhotos\' + @ItemCode + '_'+ @ColorCode + '.jpg')
,0,@ItemCode,@ColorCode)
GO

ALTER TABLE [dbo].[prItemVariant] ENABLE TRIGGER [tr_CreatePhotoPathforVariant]
GO


