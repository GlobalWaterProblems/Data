CREATE PROCEDURE stp_OutputColumns
@column NVARCHAR(250),
@table NVARCHAR(250)
AS
BEGIN

	/*
	-- Testing:
	DECLARE @columns NVARCHAR(250), @table NVARCHAR(250)
	SET @columns = ''
	SET @table = ''
	*/

	DECLARE @s NVARCHAR(MAX) 

	SET @s = 'DECLARE @c NVARCHAR(4000)

	SELECT @c = STUFF((SELECT DISTINCT TOP 100 PERCENT ''],['' + t.' + @column + '
				FROM ' + @table + ' t
				FOR XML PATH('''')),1,2,'''') + '']''
				
	SELECT @c'

	EXECUTE sp_executesql @s

END