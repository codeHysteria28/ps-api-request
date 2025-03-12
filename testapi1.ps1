param (
    [Parameter(Mandatory)]
    [string]$PfxPath,         # Path to your .pfx file with no password
    [Parameter(Mandatory)]
    [string]$ApiUrl           # The API endpoint
)

# 1. Import the certificate from PFX
Write-Host "Importing certificate from: $PfxPath"
try {
    $ClientCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $ClientCertificate.Import($PfxPath, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)
} catch {
    Write-Host "ERROR: Failed to import PFX certificate. Details: $($_.Exception.Message)"
    exit 1
}

# 2. Display basic certificate details
Write-Host "Certificate Subject: $($ClientCertificate.Subject)"
Write-Host "Certificate Thumbprint: $($ClientCertificate.Thumbprint)"
Write-Host "NotBefore: $($ClientCertificate.NotBefore), NotAfter: $($ClientCertificate.NotAfter)"

# 3. Call the API. Switch to Invoke-WebRequest for detailed header info.
try {
    Write-Host "Making request to: $ApiUrl"
    $Response = Invoke-WebRequest -Uri $ApiUrl -Certificate $ClientCertificate -Verbose

    Write-Host "Response Status Code:" $Response.StatusCode
    Write-Host "Response Headers:"
    $Response.Headers.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)"
    }
    Write-Host "`nResponse Body:"
    Write-Host $Response.Content

    # Safely check for request headers
    if ($Response -and $Response.BaseResponse -and $Response.BaseResponse.RequestMessage -and $Response.BaseResponse.RequestMessage.Headers) {
        Write-Host "`nRequest Headers:"
        $Response.BaseResponse.RequestMessage.Headers.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)"
        }
    } else {
        Write-Host "`nNo request header information available."
    }

} catch {
    Write-Host "ERROR: Client certificate validation failed or other request error."
    Write-Host "Details: $($_.Exception.Message)"
    exit 1
}