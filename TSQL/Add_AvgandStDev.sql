/*

	Adds average and standard deviation to a data set; the average and standard deviation will appear as the 
	calculated form of the previous row's to the current row's data.
	
	This stored procedure requires the table to have an incrementing ID field and requires the parameters @t
	for the table name, @id for the name of the ID field, and @v for the value that the average and standard
	deviation will be calculated.

*/

CREATE PROCEDURE stp_AddAvgAndStDev
@t NVARCHAR(500), @id NVARCHAR(100), @v NVARCHAR(250)
AS
BEGIN

	DECLARE @f NVARCHAR(MAX)
	SET @f = 'ALTER TABLE ' + @t + ' ADD ' + @v + 'Avg DECIMAL(13,4), ' + @v + 'StDev DECIMAL(13,4)'
	
	EXEC sp_executesql @f

	IF @@ERROR = 0
	BEGIN
		DECLARE @s NVARCHAR(MAX)
		SET @s = 'DECLARE @b INT = 1, @m INT, @sd DECIMAL(13,4), @av DECIMAL(13,4)
		SELECT @m = MAX(' + @id + ') FROM ' + @t + '
		
		WHILE @b <= @m
		BEGIN
		
			IF @b > 1
			BEGIN
				SELECT @sd = STDEV(' + @v + ') FROM ' + @t + ' WHERE ' + @id + ' BETWEEN 1 AND @b
				SELECT @av = AVG(' + @v + ') FROM ' + @t + ' WHERE ' + @id + ' BETWEEN 1 AND @b
				
				UPDATE ' + @t + '
				SET ' + @v + 'StDev = @sd
					, ' + @v + 'Avg = @av
				WHERE ' + @id + ' = @b
			END
			ELSE
			BEGIN
				PRINT ''No first value.''
			END
		
			SET @b = @b + 1
		
		END'
		
		EXEC sp_executesql @s
	END
	ELSE
	BEGIN
		PRINT 'Check first step.'
	END

END

EXECUTE stp_AddAvgAndStDev 'WaterTable','ID','WaterMeasurement'