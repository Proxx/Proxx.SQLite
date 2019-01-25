Describe "Convert-SQLiteType" {
    It "should not Throw" {
        { Convert-SQLiteType } | Should Not Throw
    }
    it "returns string object" {
        (Convert-SQLiteType) -is [String] | Should Be $true
    }
    Context "type conversion" {
        it "converts 'Boolean' to the right type" { Convert-SQLiteType -Type Boolean | Should Be "BOOLEAN" }
        it "converts 'Byte[]' to the right type" { Convert-SQLiteType -Type Byte[] | Should Be "BLOB" }
        it "converts 'Byte' to the right type" { Convert-SQLiteType -Type Byte | Should Be "BLOB" }
        it "converts 'Char' to the right type" { Convert-SQLiteType -Type Char | Should Be "TEXT" }
        it "converts 'Datetime' to the right type" { Convert-SQLiteType -Type Datetime | Should Be "DATETIME" }
        it "converts 'Decimal' to the right type" { Convert-SQLiteType -Type Decimal | Should Be "DECIMAL" }
        it "converts 'Double' to the right type" { Convert-SQLiteType -Type Double | Should Be "INT" }
        it "converts 'Guid' to the right type" { Convert-SQLiteType -Type Guid | Should Be "BLOB" }
        it "converts 'Int16' to the right type" { Convert-SQLiteType -Type Int16 | Should Be "INT" }
        it "converts 'Int32' to the right type" { Convert-SQLiteType -Type Int32 | Should Be "INT" }
        it "converts 'Int64' to the right type" { Convert-SQLiteType -Type Int64 | Should Be "INT" }
        it "converts 'UInt16' to the right type" { Convert-SQLiteType -Type Int16 | Should Be "INT" }
        it "converts 'UInt32' to the right type" { Convert-SQLiteType -Type Int32 | Should Be "INT" }
        it "converts 'UInt64' to the right type" { Convert-SQLiteType -Type Int64 | Should Be "INT" }
        it "converts 'Single' to the right type" { Convert-SQLiteType -Type Single | Should Be "NUMERIC" }
        it "converts 'STring' to the right type" { Convert-SQLiteType -Type String | Should Be "TEXT" }
        it "converts 'all exceptions' to string type" { Convert-SQLiteType -Type defialtTest | Should Be "TEXT" }

    }

}
    