section Section1;

shared SqlServerInstance = "POWERBI-SQL" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared SqlServerDatabase = "AdventureWorksDW2020-DAX-Docs" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Sales Territory" = let
    Source = Sql.Database(SqlServerInstance, SqlServerDatabase),
    dbo_DimSalesTerritory = Source{[Schema="dbo",Item="DimSalesTerritory"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_DimSalesTerritory,{"SalesTerritoryKey", "SalesTerritoryRegion", "SalesTerritoryCountry", "SalesTerritoryGroup"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"SalesTerritoryRegion", "Region"}, {"SalesTerritoryCountry", "Country"}, {"SalesTerritoryGroup", "Group"}}),
    AutoRemovedColumns1 = 
    let
        t = Table.FromValue(#"Renamed Columns", [DefaultColumnName = "Sales Territory"]),
        removed = Table.RemoveColumns(t, Table.ColumnsOfType(t, {type table, type record, type list}))
    in
        Table.TransformColumnNames(removed, Text.Clean)
in
    AutoRemovedColumns1;