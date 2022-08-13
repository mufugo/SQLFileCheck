CREATE TRIGGER [dbo].[tr_DeletePhotoPathforVariant]
ON [dbo].[prItemVariant] AFTER DELETE
AS

/*


Author: Muhammet Furkan GÖKDEMÝR (MUFUGO)
Created Date: 22.03.2022 - 16:00 (04:00 PM)
Last Update Date: 13.08.2022 - 11:00 (AM)

Description;

Trigger ile eðer ürün tablosuna mevcut bir kayýt silinirse ilgili kaydýn dosya konumunu FileList tablosundan siliniyor.
With Trigger, if an existing record is deleted in the product table, the file location of the corresponding record is deleted from the FileList table.

*/

DECLARE @ItemCode NVARCHAR(MAX)
DECLARE @ColorCode NVARCHAR(MAX)
SELECT @ItemCode = ItemCode, @ColorCode = ColorCode FROM Deleted WHERE Deleted.ColorCode NOT IN (SELECT ColorCode FROM dbo.prItemVariant)

IF (SELECT COUNT(*) FROM FileList WHERE ItemCode = @ItemCode AND ColorCode = @ColorCode ) > 0
	DELETE FileList WHERE ItemCode = @ItemCode AND ColorCode = @ColorCode
GO

ALTER TABLE [dbo].[prItemVariant] ENABLE TRIGGER [tr_DeletePhotoPathforVariant]
GO


