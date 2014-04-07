/*

	This procedure will create a table without outliers from a data set with the same table name and _NoOutliers.
	The procedure requires the table name, the value for the standard deviation calculation and the deviation
	amount.  It assumes that the table has an average, standard deviation and id attached.

*/

CREATE PROCEDURE stp_RemoveOutliers
@t NVARCHAR(500), @v NVARCHAR(250), @dev DECIMAL(3,1)
AS
BEGIN

	DECLARE @avg NVARCHAR(250), @stdev NVARCHAR(250), @id NVARCHAR(250)
	SELECT @id = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @t AND COLUMN_NAME LIKE 'ID%'
	SELECT @avg = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @t AND COLUMN_NAME LIKE '%Avg%'
	SELECT @stdev = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = @t AND COLUMN_NAME LIKE '%StDev%'

	DECLARE @s NVARCHAR(MAX)
	SET @s = ';WITH OutOutlier AS(
		SELECT ' + @id + ' NewID
			, ' + @v + ' OutValue
			, (' + @avg + ' + (' + @stdev + ' *' + CAST(@dev AS NVARCHAR(3)) + ')) ThreeAbove
			, (' + @avg + ' + (' + @stdev + ' *-' + CAST(@dev AS NVARCHAR(3)) + ')) ThreeBelow
		FROM ' + @t + '
	)
	SELECT ROW_NUMBER() OVER (ORDER BY ' + @id + ') NoOutlierID
		, t2.*
	INTO ' + @t + '_NoOutliers
	FROM OutOutlier t
		INNER JOIN ' + @t + ' t2 ON t.NewID = t2.' + @id + '
	WHERE t.OutValue BETWEEN ThreeBelow AND ThreeAbove
	
	ALTER TABLE ' + @t + '_NoOutliers DROP COLUMN ' + @id

	EXEC sp_executesql @s
	
END

EXECUTE stp_RemoveOutliers 'WaterTable','WaterMeasurement',1