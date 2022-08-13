/* 

Author: Muhammet Furkan GÖKDEMÝR (MUFUGO)
Created Date: 22.03.2022 - 21:00 (09:00 PM)
Last Update Date: 13.08.2022 - 10:30 (10:30 AM)

Description;

FileList adý altýnda bir tablo oluþturur, bu kontrol edilen dosyalarýn listesini içerir.

EN;

Creates a table under the name FileList, which contains the list of checked files.

*/
CREATE TABLE [dbo].[FileList](
	[file_name] [NVARCHAR](250) NULL,
	[file_exist] [BIT] NULL,
	[ItemCode] [NVARCHAR](250) NULL,
	[ColorCode] [NVARCHAR](250) NULL
) ON [PRIMARY]

