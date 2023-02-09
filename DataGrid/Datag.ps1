#Añadimos el assembly type primero

Add-Type -AssemblyName PresentationFramework

#Path al XAML
$xamlFile = "C:\Users\fpedraza\Desktop\PowerShell\DataGrid\dgxaml.xaml"

#Sacar content raw y hacer replace para poder crear objeto XML
$inputXAML = Get-Content -Path $xamlFile -Raw
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace '^<Win.*','<Window'

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

$columns = @('DisplayName','Status','ServiceName')
$data = Get-Service | select $columns

#Create dataTable
$dataT = New-Object System.Data.DataTable
[void]$dataT.Columns.AddRange($columns)
#Add Rows
foreach($row in $data)
{
    [void]$dataT.Rows.Add(@($row.DisplayName,$row.Status,$row.ServiceName))
}

$var_dg.ItemsSource=$dataT.DefaultView
$var_dg.IsReadOnly = $true # If read only is needed
$var_dg.GridLinesVisibility="None"

$var_dg.Add_SelectionChanged({
    $var_lbl_servicename.Content = $var_dg.SelectedItem.ServiceName
    $var_lbl_status.Content = $var_dg.SelectedItems.Status
})


$var_txtb_filter.Add_TextChanged({
    $filter = "DisplayName  LIKE '$($var_txtb_filter.Text)%'"
    $dataT.DefaultView.RowFilter=$filter
})


$psform.WindowStartupLocation ="Centerscreen"
$psform.ShowDialog()

