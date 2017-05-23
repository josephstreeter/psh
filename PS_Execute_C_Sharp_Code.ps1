$source = @"
public class BasicTest
{
    public static int Add(int a, int b)
    {
        return (a + b);
    }

    public int Multiply(int a, int b)
    {
        return (a * b);
    }
    
    public int Subtract(int a, int b)
    {
        return (a - b);
    }
}
"@

Add-Type -TypeDefinition $source

$basicTestObject = New-Object BasicTest 
$basicTestObject.Multiply(5, 2)