section Section1;

shared SqlServerInstance = "POWERBI-SQL" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared SqlServerDatabase = "AdventureWorksDW2020-DAX-Docs" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared Sales = let
    Source = Sql.Database(SqlServerInstance, SqlServerDatabase),
    dbo_vFactSales = Source{[Schema="dbo",Item="vFactSales"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_vFactSales,{"SalesOrderLineKey", "ResellerKey", "CustomerKey", "ProductKey", "OrderDateKey", "DueDateKey", "ShipDateKey", "SalesTerritoryKey", "OrderQuantity", "UnitPrice", "ExtendedAmount", "UnitPriceDiscountPct", "ProductStandardCost", "TotalProductCost", "SalesAmount"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"OrderQuantity", Int64.Type}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"ExtendedAmount", "Extended Amount"}, {"OrderQuantity", "Order Quantity"}, {"ProductStandardCost", "Product Standard Cost"}, {"SalesAmount", "Sales Amount"}, {"TotalProductCost", "Total Product Cost"}, {"UnitPrice", "Unit Price"}, {"UnitPriceDiscountPct", "Unit Price Discount Pct"}}),
    AutoRemovedColumns1 = 
    let
        t = Table.FromValue(#"Renamed Columns", [DefaultColumnName = "Sales"]),
        removed = Table.RemoveColumns(t, Table.ColumnsOfType(t, {type table, type record, type list}))
    in
        Table.TransformColumnNames(removed, Text.Clean)
in
    AutoRemovedColumns1;