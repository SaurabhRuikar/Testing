section Section1;

shared SqlServerInstance = "POWERBI-SQL" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared SqlServerDatabase = "AdventureWorksDW2020-DAX-Docs" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared Reseller = let
    Source = Sql.Database(SqlServerInstance, SqlServerDatabase),
    dbo_DimReseller = Source{[Schema="dbo",Item="DimReseller"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_DimReseller,{"ResellerKey", "ResellerAlternateKey", "BusinessType", "ResellerName", "DimGeography"}),
    #"Expanded DimGeography" = Table.ExpandRecordColumn(#"Removed Other Columns", "DimGeography", {"City", "StateProvinceName", "EnglishCountryRegionName", "PostalCode"}, {"City", "StateProvinceName", "EnglishCountryRegionName", "PostalCode"}),
    #"Add NA Row" = Table.InsertRows(#"Expanded DimGeography", 0, {[ResellerKey = -1, ResellerAlternateKey = "[Not Applicable]", BusinessType = "[Not Applicable]", ResellerName = "[Not Applicable]", City = "[Not Applicable]", StateProvinceName ="[Not Applicable]", EnglishCountryRegionName ="[Not Applicable]", PostalCode ="[Not Applicable]"]}),
    #"Renamed Columns" = Table.RenameColumns(#"Add NA Row",{{"ResellerAlternateKey", "Reseller ID"}, {"BusinessType", "Business Type"}, {"ResellerName", "Reseller"}, {"StateProvinceName", "State-Province"}, {"EnglishCountryRegionName", "Country-Region"}, {"PostalCode", "Postal Code"}}),
    AutoRemovedColumns1 = 
    let
        t = Table.FromValue(#"Renamed Columns", [DefaultColumnName = "Reseller"]),
        removed = Table.RemoveColumns(t, Table.ColumnsOfType(t, {type table, type record, type list}))
    in
        Table.TransformColumnNames(removed, Text.Clean)
in
    AutoRemovedColumns1;