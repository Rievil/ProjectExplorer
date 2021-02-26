USE Projects
GO

declare @command varchar(15)  
set @command = 'drop table ?'  
exec sp_msforeachtable @command