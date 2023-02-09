#Añadimos el assembly type primero

Add-Type -AssemblyName PresentationFramework

#Path al XAML
$xamlFile = "C:\Users\fpedraza\Desktop\PowerShell\CSV_splitter\MainWindow.xaml"

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

#Comprobar esas VARIABLES
#Get-Variable var_*

#Rellenar combo box
Get-Service | ForEach-Object{$var_service_combob.Items.Add($_.Name)}

function GetDetails{
    
    $ServiceName = $var_service_combob.SelectedItem
    $details = Get-Service -Name $ServiceName | select *
    $var_lbl_servicename.Content = $details.Name
    $var_lbl_status.Content = $details.status
    if ($var_lbl_status.Content -eq 'Running')
    {
        $var_lbl_status.Foreground='green'
    }else{
        $var_lbl_status.Foreground='red'
    }
}

#Aplicar cambios al seleccionar la combo box
$var_service_combob.Add_SelectionChanged({GetDetails})

$psform.ShowDialog()