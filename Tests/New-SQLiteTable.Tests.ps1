Describe "New-SQLiteTable" {
    BeforeAll {
        Function Get-RandomList($Count=100) {
            $Names = @('Francoise','Johnson','Latanya','Assunta','Shae','Verda','Desiree','Renetta','Kimber','Magda','Gertrude','Chastity','Karleen','Glenna','Aleisha','Adrian','Golden','Kellye','Rubin','Grant','Abraham','Lovetta','Elda','Shemeka','Liliana','Lucius','Davis','Ming','Lashanda','Beata')
            $Address = @('413 Willow Street Neenah, WI 54956','226 Broad Street Indiana, PA 15701','455 Willow Lane Cheshire, CT 06410','365 Willow Lane Xenia, OH 45385','249 Route 41 Alabaster, AL 35007', '412 3rd AvenueWoonsocket, RI 02895','174 George Street Mahopac, NY 10541','304 Linda Lane Augusta, GA 30906','83 Willow Street San Carlos, CA 94070','737 Monroe Drive Pompano Beach, FL 33060','168 Pleasant Street Stafford, VA 22554','374 Route 64 Salem, MA 01970','82 Pleasant Street Fort Lee, NJ 07024','170 Rose Street Henderson, KY 42420','260 Street Road New Hyde Park, NY 11040','643 Route 10 Cary, NC 27511','279 Hillcrest Avenue Savage, MN 55378','472 River Road Pearl, MS 39208','34 3rd Avenue West Lafayette, IN 47906','534 Garden Street Powder Springs, GA 30127')
            $Numbers = @(10000..90000)
            1..$Count | %{ 
        
                Write-Output -InputObject (New-Object -TypeName PSObject -Property @{
                    Name = Get-Random -InputObject $Names
                    Address = Get-Random -InputObject $Address
                    Number = Get-Random -InputObject $Numbers
                })
            }
        }

        $Location = Join-Path $TestDrive database.db
        $conn = Connect-SQLite -Database $Location -Open
        $Data = Get-RandomList -Count 100
    }
    AfterAll {
        $Conn.Close()
        $conn.Dispose()
        Remove-Variable -Name conn
    }
    It "should not throw" {
        { $Data | New-SQLiteTable -Connection $conn -Name Test } | Should Not Throw
    }
    it "returns True on success" {
        $Data | New-SQLiteTable -Connection $conn -Name Test | Select -Last 1 | Should Be $true
    }
    Context "PassThru" {
        BeforeAll {
            Function Get-RandomList($Count=100) {
                $Names = @('Francoise','Johnson','Latanya','Assunta','Shae','Verda','Desiree','Renetta','Kimber','Magda','Gertrude','Chastity','Karleen','Glenna','Aleisha','Adrian','Golden','Kellye','Rubin','Grant','Abraham','Lovetta','Elda','Shemeka','Liliana','Lucius','Davis','Ming','Lashanda','Beata')
                $Address = @('413 Willow Street Neenah, WI 54956','226 Broad Street Indiana, PA 15701','455 Willow Lane Cheshire, CT 06410','365 Willow Lane Xenia, OH 45385','249 Route 41 Alabaster, AL 35007', '412 3rd AvenueWoonsocket, RI 02895','174 George Street Mahopac, NY 10541','304 Linda Lane Augusta, GA 30906','83 Willow Street San Carlos, CA 94070','737 Monroe Drive Pompano Beach, FL 33060','168 Pleasant Street Stafford, VA 22554','374 Route 64 Salem, MA 01970','82 Pleasant Street Fort Lee, NJ 07024','170 Rose Street Henderson, KY 42420','260 Street Road New Hyde Park, NY 11040','643 Route 10 Cary, NC 27511','279 Hillcrest Avenue Savage, MN 55378','472 River Road Pearl, MS 39208','34 3rd Avenue West Lafayette, IN 47906','534 Garden Street Powder Springs, GA 30127')
                $Numbers = @(10000..90000)
                1..$Count | %{ 
            
                    Write-Output -InputObject (New-Object -TypeName PSObject -Property @{
                        Name = Get-Random -InputObject $Names
                        Address = Get-Random -InputObject $Address
                        Number = Get-Random -InputObject $Numbers
                    })
                }
            }
            $Location = Join-Path $TestDrive database.db
            $conn = Connect-SQLite -Database $Location -Open
            $Data = Get-RandomList -Count 100
        }
        AfterAll {
            $Conn.Close()
            $conn.Dispose()
            Remove-Variable -Name conn
        }
        it "shoud pass all values trough the pipe" {
            Compare-Object -DifferenceObject ($Data | New-SQLiteTable -Connection $conn -Name Test -PassThru) -ReferenceObject $Data | Should BeNullOrEmpty
        }
    }
}













<#

    New-sqlitable
        should not throw
        passthru
            outputs unmodified data
        AllText
            







#>