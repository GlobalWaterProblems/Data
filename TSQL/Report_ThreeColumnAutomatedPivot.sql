CREATE PROCEDURE stp_ThreeColumnPivot
@PivotColumn VARCHAR(250),
@CalcColumn VARCHAR(250),
@NonPivotColumn VARCHAR(250),
@SourceTable VARCHAR(250),
@Function VARCHAR(10)
AS
BEGIN

	DECLARE @c NVARCHAR(4000), @sql NVARCHAR(MAX)

	DECLARE @s TABLE(
		S NVARCHAR(4000)
	)

	INSERT INTO @s
	EXECUTE stp_OutputColumns @PivotColumn, @SourceTable

	SELECT @c = S FROM @s

	SET @sql = N'SELECT ' + @NonPivotColumn + ', ' + @c + ' FROM (SELECT t.' + @NonPivotColumn + ', t.' + @PivotColumn + ', t.' + @CalcColumn + ' FROM ' + @SourceTable + ' t) p
				PIVOT (' + @Function + '(' + @CalcColumn + ') FOR ' + @PivotColumn + ' IN (' + @c + ')) AS pv;'

	EXEC sp_executesql @sql

END