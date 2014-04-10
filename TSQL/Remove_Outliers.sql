/*

	This procedure will create a table without outliers from a data set with the same table name and _NoOutliers.
	The procedure requires the table name, the value for the standard deviation calculation and the deviation
	amount.  It assumes that the table has an average, standard deviation and id attached.

*/

CREATE PROCEDURE stp_RemoveOutliers
@t NVARCHAR(100), @v NVARCHAR(100), @dev DECIMAL(3,1), @sh NVARCHAR(15)
AS
BEGIN

	DECLARE @avg NVARCHAR(250), @stdev NVARCHAR(250), @id NVARCHAR(250), @to NVARCHAR(100)
	SELECT @id = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @t AND COLUMN_NAME LIKE 'ID%'
	SELECT @avg = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @t AND COLUMN_NAME LIKE 'Avg%'
	SELECT @stdev = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = @t AND COLUMN_NAME LIKE 'StDev%'
	--SET @to = @t + '_NoOutliers'
	SET @to = QUOTENAME(@sh) + '.' + QUOTENAME(@t + '_NoOutliers')


	DECLARE @s NVARCHAR(MAX)
	SET @s = N'IF OBJECT_ID(@to) IS NULL
	BEGIN
	
		;WITH OutOutlier AS(
			SELECT ' + @id + ' NewestID
				, ' + @v + ' OutValue
				, (' + @avg + ' + (' + @stdev + ' *' + CAST(@dev AS NVARCHAR(3)) + ')) OAbove
				, (' + @avg + ' + (' + @stdev + ' *-' + CAST(@dev AS NVARCHAR(3)) + ')) OBelow
			FROM ' + QUOTENAME(@sh) + '.' + QUOTENAME(@t) + '
		)
		SELECT ROW_NUMBER() OVER (ORDER BY ' + @id + ') NoOutlierID
			, t2.*
		--INTO ' + QUOTENAME(@t + '_NoOutliers') + '
		INTO ' + QUOTENAME(@sh) + '.' + QUOTENAME(@t + '_NoOutliers') + '
		FROM OutOutlier t
			INNER JOIN ' + QUOTENAME(@sh) + '.' + QUOTENAME(@t) + ' t2 ON t.NewestID = t2.' + @id + '
		WHERE t.OutValue BETWEEN OBelow AND OAbove
		
		--ALTER TABLE ' + QUOTENAME(@t + '_NoOutliers') + ' DROP COLUMN ' + @id + '
		ALTER TABLE ' + QUOTENAME(@sh) + '.' + QUOTENAME(@t + '_NoOutliers') + ' DROP COLUMN ' + @id + '
	END'

	--PRINT @s
	EXEC sp_executesql @s,N'@to NVARCHAR(100)',@to

END

EXECUTE stp_RemoveOutliers 'WaterTable','WaterMeasurement',1,'wtr'
