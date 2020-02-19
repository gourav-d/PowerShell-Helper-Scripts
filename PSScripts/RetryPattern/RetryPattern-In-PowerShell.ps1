function RetryCommand {
    [CmdletBinding()]
    param(
        [scriptblock]
        [Parameter(Mandatory = $true, HelpMessage = "Retry Script")]
        $Command,

        [int]
        [Parameter(Mandatory = $false, HelpMessage = "Delay between retries in seconds")]
        $RetryDelay = 2,

        [int]
        [Parameter(Mandatory = $false, HelpMessage = "Maximum retry attempts")]
        $MaxRetry = 3,

        [scriptblock]
        [Parameter(Mandatory = $false, HelpMessage = "Block of code execute when an exception occurs")]
        $ExceptionCallBack
    )

    $retryAttempt = 0
    $isCompleted = $false
    $ErrorActionPreferenceToRestore = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    while (($retryAttempt -lt $MaxRetry) -and (-not $isCompleted )) {

        $retryAttempt = $retryAttempt + 1
        
        try
        {
            if($null -eq $Command) {
                Write-Host "Invalid Command parameter"
                return
            }

            & $Command -currentRetryAttempt $retryAttempt
            return;
        }
        catch [System.Exception] {

            if ($retryAttempt -lt $MaxRetry) {

                Write-Host ("Execution failed. Retrying attempt $retryAttempt.")
            }
            else {
                $ErrorActionPreference = $ErrorActionPreferenceToRestore
                return
            }

            if($null -ne $ExceptionCallBack) {
                & $ExceptionCallBack -exception $_.Exception
            }
        }
        
        if ($RetryDelay -gt 0 -and (-not $isCompleted)) {
            Write-Host "Waiting for $RetryDelay seconds before retrying..."
            Start-Sleep -s $RetryDelay
            Write-Host "Retrying..."
        }        
    }

    $ErrorActionPreference = $ErrorActionPreferenceToRestore
}





#How to use:

#Positive Test Case
RetryCommand -Command { 
    
    Write-Host "Hello World!!!"

} -MaxRetry 3



#Negative Test Case
RetryCommand -Command { 
    
    Write-Host "Exception is going to occur"
    throw 'logic throw exception'

} -MaxRetry 3 -RetryDelay 2 -ExceptionCallBack {
    param($exception)
    Write-ErrorLog "Here is your exception info:: $($exception.Message)"
}