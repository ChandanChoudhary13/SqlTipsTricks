
-- =============================================
-- Author:      Chandan Choudhary
-- Create Date: 19 July 2020
-- Description: To Generate DTO or c# Model from Table.
-- =============================================

DECLARE @tableName NVARCHAR(MAX), @schemaName NVARCHAR(MAX), @className NVARCHAR(MAX)
 
--------------- Input arguments [Start] ---------------
SET @schemaName = 'Vendor'       --- TODO : Change it to your Schema Name
SET @tableName = 'Products'	  --- TODO : Change it to your Table Name
SET @className = 'VendorProducts' --- TODO : Change it to your Desired Class | Model | DTO Name
--------------- Input arguments [End]  -----------

	DECLARE tableColumns CURSOR LOCAL FOR
	SELECT 
	-- schema_name(tab.schema_id) as schema_name, tab.name as table_name, col.column_id, col.name as column_name, t.name as data_type, col.max_length, col.precision
	col.name, col.system_type_id, col.is_nullable
	FROM SYS.TABLES as tab
	INNER JOIN SYS.COLUMNS as col on tab.object_id = col.object_id
	LEFT JOIN SYS.TYPES as t on col.user_type_id = t.user_type_id
	Where schema_name(tab.schema_id) =@schemaName
	and  tab.name=@tableName
 
	PRINT 'public class ' + @className
	PRINT '{'
 
	OPEN tableColumns
	DECLARE @name NVARCHAR(MAX), @typeId INT, @isNullable BIT, @typeName NVARCHAR(MAX)
	FETCH NEXT FROM tableColumns INTO @name, @typeId, @isNullable
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @typeName =
		CASE @typeId
				WHEN 36 THEN 'Guid'
				WHEN 56 THEN 'int'
				WHEN 127 THEN 'long'
				WHEN 59 THEN 'decimal'
				WHEN 61 THEN 'DateTime'
				WHEN 104 THEN 'bool'
				WHEN 106 THEN 'double'
				WHEN 231 THEN 'string'
				WHEN 239 THEN 'string'
				WHEN 167 THEN 'string'
				WHEN 241 THEN 'XElement'
			ELSE 'TODO(' + CAST(@typeId AS NVARCHAR) + ')'
		END;
		IF @isNullable = 1 AND @typeId != 231 AND @typeId != 239 AND @typeId != 241
			SET @typeName = @typeName + (CASE WHEN @typeName='string' THEN '' ELSE '?' END)
		PRINT '    public ' + @typeName + ' ' + @name + ' { get; set; }'	
		FETCH NEXT FROM tableColumns INTO @name, @typeId, @isNullable
	END
 
	PRINT '}'
 
CLOSE tableColumns