#Añadimos el assembly type primero

Add-Type -AssemblyName PresentationFramework

#Path al XAML
$xamlFile = "C:\Users\fpedraza\Desktop\PowerShell\csv\csvsplitter.xaml"

#Sacar content raw y hacer replace para poder crear objeto XML
$inputXAML = Get-Content -Path $xamlFile -Raw
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:Name","Name" -replace '^<Win.*','<Window'

#Crear objeto XML
[XML]$XAML = $inputXAML

#Objeto lector del objeto XAML
$reader = New-Object System.Xml.XmlNodeReader $XAML

try
{
	#tratar de cargar el XAML a un form de PS1
	$psform=[Windows.Markup.XamlReader]::Load($reader)
}
catch
{
	write-host $_:Exception
	throw
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {

	try
	{
		Set-Variable -Name "var_$($_.Name)" -Value $psform.FindName($_.Name) -ErrorAction Stop
	}
	catch
	{
		throw
	}

}

$var_fi_btn.Add_Click({
    $InputFile = New-Object System.Windows.Forms.OpenFileDialog
    $InputFile.ShowDialog()
    $var_fi_txtb.Text = $InputFile.FileName
    

})

$var_fo_btn.Add_Click({
    $OutpuFolder = New-Object System.Windows.Forms.FolderBrowserDialog
    $OutpuFolder.ShowDialog()
    $var_fo_txtB.Text = $OutpuFolder.SelectedPath

})

$var_split_btn.Add_Click({
    $var_listB.Items.Clear() 
    $sourcefile = $var_fi_txtb.Text
    $df = Import-Csv -Delimiter $var_delimiter_txtB.Text -Path $sourcefile

    #Sacar filas
    $rowsperfile = $($df.Count)/$($var_nfiles_txtB.Text)
    $startrow = 0
    $counter = 0

    While($startrow -le $df.Count)
    {
        Import-Csv -Path $sourcefile | select -skip $startrow -First $rowsperfile | Export-Csv -Path "$($var_fo_txtB.Text)\output-$($counter).csv" 
        $var_listB.Items.Add("$($var_fo_txtB)\output-$($counter).csv was created!")
        $startrow += $rowsperfile
        $counter+=1 
    }
})


$psform.ShowDialog()