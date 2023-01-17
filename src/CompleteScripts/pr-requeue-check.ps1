$org = "prxm"
$project = "jarvis"
$pat = "put-your-personal-access-token-here"

# Set the API endpoint URL for pull requests
$pullRequestUrl = "https://dev.azure.com/$org/$project/_apis/git/pullrequests?status=active&api-version=6.1"

# Set the headers for the API call
$headers = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Basic $( [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)")) )"
}

# Send the GET request to the API endpoint to get the pull requests
$pullRequests = Invoke-RestMethod -Uri $pullRequestUrl -Headers $headers -Method Get

# Take all the builds that are issued by a pull requests
# In reality this is a dead end, we need to check policies not directly builds.
# $BuildUrl = "https://dev.azure.com/$org/$project/_apis/build/builds?reasonFilter=pullRequest&api-version=6.1"
# $builds = Invoke-RestMethod -Uri $BuildUrl -Headers $headers -Method Get

# Iterate through the pull requests
foreach ($pullRequest in $pullRequests.value) {
    
    Write-Host "Checking pull request $($pullRequest.pullRequestId)"
    $projectId = $pullRequest.repository.project.id
    $pullRequestId = $pullRequest.pullRequestId

    $artifactId = "vstfs:///CodeReview/CodeReviewId/$projectId/$pullRequestId"
    $policyEvaluationUrl = "https://dev.azure.com/$org/$project/_apis/policy/evaluations?artifactId=$artifactId&api-version=7.0-preview.1"
 
    # Send the GET request to the API endpoint to get the build status of the pull request
    $policyEvaluation = Invoke-RestMethod -Uri $policyEvaluationUrl -Headers $headers -Method Get
    
    $isExpired = $false
    if ($policyEvaluation.count -gt 0) {
        Write-Host "Pull request $pullRequestId has $($policyEvaluation.count) policy evaluations"
        foreach ($evaluation in $policyEvaluation.value) {
            if ($evaluation.context.isExpired) {
                Write-Host "Policy $($evaluation.configuration.displayName) is expired pull request $pullRequestId policies must be reevaluated"
                $isExpired = $true
                $policyRequeueUrl = "https://dev.azure.com/$org/$project/_apis/policy/evaluations/$($evaluation.evaluationId)?api-version=7.0-preview.1"
                $policyEvaluation = Invoke-RestMethod -Uri $policyRequeueUrl -Headers $headers -Method PATCH
            }
        }
    }

    # If the build is expired, output the pull request details
    if ($isExpired) {
        Write-Output "Pull Request ID: $($pullRequest.pullRequestId) has expired policies that were requeued"
    }
    else {
        Write-Output "Pull Request ID: $($pullRequest.pullRequestId) IS ok"
    }
}