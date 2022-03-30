section Section1;

shared SqlServerInstance = "POWERBI-SQL" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared SqlServerDatabase = "AdventureWorksDW2020-DAX-Docs" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Sales Order" = let
    Source = Sql.Database(SqlServerInstance, SqlServerDatabase),
    dbo_vFactSales = Source{[Schema="dbo",Item="vFactSales"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_vFactSales,{"Channel", "SalesOrderLineKey", "SalesOrderNumber", "SalesOrderLineNumber"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"SalesOrderNumber", "Sales Order"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Sales Order Line", each [Sales Order] & " - " & Text.PadStart(Number.ToText([SalesOrderLineNumber]), 2, "0")),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"Sales Order Line", type text}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"SalesOrderLineNumber"}),
    AutoRemovedColumns1 = 
    let
        t = Table.FromValue(#"Removed Columns", [DefaultColumnName = "Sales Order"]),
        removed = Table.RemoveColumns(t, Table.ColumnsOfType(t, {type table, type record, type list}))
    in
        Table.TransformColumnNames(removed, Text.Clean)
in
    AutoRemovedColumns1;