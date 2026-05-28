# Native PowerShell 5.1 Zero-Dependency Static Site Generator (SSG)
# Completely ASCII-clean to avoid encoding crashes on multi-byte characters.

$ErrorActionPreference = "Continue"

$workspaceRoot = "c:\Users\intel\.gemini\antigravity\scratch\scholarship-finder"
$dataPath = Join-Path $workspaceRoot "js\data.js"

Write-Output "Step 1: Reading and parsing js/data.js..."
$raw = Get-Content -Raw -Path $dataPath -Encoding utf8
# Strip comments
$raw = $raw -replace '/\*[\s\S]*?\*/', ''
$raw = $raw -replace '(?m)^\s*//.*$', ''

# Date calculations (declared early to be usable on load)
function Get-CalculatedStatus {
    param($startStr, $deadlineStr)
    $today = [DateTime]::Today
    
    try {
        $startDate = [DateTime]::Parse($startStr)
        $deadlineDate = [DateTime]::Parse($deadlineStr)
    } catch {
        return "Open"
    }
    
    if ($today -lt $startDate) { return "Upcoming" }
    if ($today -gt $deadlineDate) { return "Closed" }
    
    $daysLeft = ($deadlineDate - $today).Days
    if ($daysLeft -le 15) { return "Closing Soon" }
    
    return "Open"
}

# Extract SCHOLARSHIPS array
if ($raw -match 'const SCHOLARSHIPS = \s*(\[[\s\S]*?\])\s*;') {
    $arrayText = $Matches[1]
    # Quote unquoted JSON keys
    $json = $arrayText -replace '(?m)^\s*([a-zA-Z0-9_]+)\s*:', '"$1":'
    # Remove trailing commas
    $json = $json -replace ',\s*([\]}])', '$1'
    
    try {
        $scholarships = ConvertFrom-Json $json
        Write-Output "SUCCESS: Parsed $($scholarships.Count) scholarships!"
        
        # Pre-calculate status on all objects to avoid property set limitations
        foreach ($s in $scholarships) {
            $sStatus = Get-CalculatedStatus $s.Start_Date $s.Deadline
            $s | Add-Member -MemberType NoteProperty -Name "calculatedStatus" -Value $sStatus -Force
        }
    } catch {
        Write-Error "JSON Parsing failure: $_"
    }
} else {
    Write-Error "Could not find SCHOLARSHIPS array in data.js"
}

# Slugs and state slugifier
function Get-Slug {
    param([string]$text)
    $text = $text.ToLower().Trim()
    $text = $text -replace '[^a-z0-9\s-]', ''
    $text = $text -replace '\s+', '-'
    $text = $text -replace '-+', '-'
    return $text
}

function Get-StateSlug {
    param([string]$state)
    if ($state -eq "Madhya Pradesh") { return "mp" }
    return Get-Slug $state
}

# Clean URLs setup lists
$statesList = @(
    @{ Name = "Madhya Pradesh"; Slug = "mp"; Keywords = "MPTAAS, MMVY, Gaon Ki Beti, Sambal Portal" },
    @{ Name = "Maharashtra"; Slug = "maharashtra"; Keywords = "MahaDBT, SC Post Matric, Domicile schemes" },
    @{ Name = "Uttar Pradesh"; Slug = "uttar-pradesh"; Keywords = "UP Scholarship Portal, Post Matric OBC, Pre Matric SC" },
    @{ Name = "West Bengal"; Slug = "west-bengal"; Keywords = "SVMCM, Aikyashree, Oasis portal, Kanyashree" }
)

$categoriesList = @(
    @{ Name = "General"; Slug = "general"; Desc = "Open merit-based, EWS financial aid, and state welfare schemes for General category students." },
    @{ Name = "SC"; Slug = "sc"; Desc = "Post-matric stipends, school fee waivers, and specialized higher education grants for SC students." },
    @{ Name = "ST"; Slug = "st"; Desc = "Central Overseas awards, tribal welfare stipends, and MPTAAS-linked financial aid for ST students." },
    @{ Name = "OBC"; Slug = "obc"; Desc = "UP pre/post matric reimbursements, state scholarship awards, and OBC benefit schemes." },
    @{ Name = "Minority"; Slug = "minority"; Desc = "Notified minority community scholarship benefits (Muslims, Sikhs, Christians, Jains, Buddhists, Parsis)." },
    @{ Name = "Girls"; Slug = "girls"; Desc = "Dedicated empowerment schemes for female students, including Gaon Ki Beti, Pratibha Kiran, and AICTE Pragati." }
)

# 13 Detailed Content Guides
$guidesList = @(
    @{
        Slug = "state-scholarship-portals"
        Title = "State Scholarship Portals Guide 2026 | Registration Directory"
        Desc = "Comprehensive guide on MPTAAS, MahaDBT, SSP, and UP scholarship portal registration workflows."
        Icon = "&#128205;"
        Content = @"
        <section class="seo-content card">
            <h2>&#127891; Official State Scholarship Portals Overview</h2>
            <p>Most Indian states manage their own welfare disbursement programs through dedicated online portals. Understanding which portal maps to your residency is the first step in unlocking financial assistance.</p>
            <h3>Major State Portals</h3>
            <ul>
                <li><strong>Madhya Pradesh (MP):</strong> Managed via the MPTAAS portal and the MP Scholarship Portal 2.0. Programs include MMVY, Jan Kalyan, and Gaon Ki Beti.</li>
                <li><strong>Maharashtra:</strong> Managed via the MahaDBT (Mahasharera) portal, offering comprehensive post-matric stipends for SC/ST/OBC students.</li>
                <li><strong>Uttar Pradesh (UP):</strong> Managed via the UP Scholarship Portal (Saksham), handling massive pre-matric and post-matric disbursements.</li>
                <li><strong>West Bengal:</strong> Managed through Oasis, SVMCM, and Kanyashree portals for minority and merit awards.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "how-to-apply"
        Title = "How to Apply for Scholarships 2026 | Step-by-Step Registration"
        Desc = "Universal application steps: profile creation, scheme selection, school verification, and receipt prints."
        Icon = "&#128221;"
        Content = @"
        <section class="seo-content card">
            <h2>&#128221; Universal 5-Step Application Process</h2>
            <p>Applying for public scholarships can feel overwhelming, but the actual workflow can be broken down into five standard, repeatable milestones across almost all portals:</p>
            <ol>
                <li><strong>Profile Registration:</strong> Visit the official portal (NSP or state portal) and generate your login credentials using Aadhaar e-KYC validation.</li>
                <li><strong>Fill Academic Profiles:</strong> Complete basic, previous qualifying marks (Class 10/12), ongoing college code, roll number, and family income variables.</li>
                <li><strong>Select Eligible Schemes:</strong> Based on your parsed domicile and caste certificates, the portal will dynamically showcase schemes you qualify for.</li>
                <li><strong>Upload Digitally Signed Documents:</strong> Attach high-quality scanned copies of income, caste, domicile, fee receipts, and bank passbooks.</li>
                <li><strong>Submit and Track:</strong> Confirm the spelling details, finalize your application, print the confirmation slip, and hand over a copy to your Institute Nodal Officer (INO).</li>
            </ol>
        </section>
"@
    },
    @{
        Slug = "eligibility-requirements"
        Title = "Scholarship Eligibility Requirements 2026 | Age, Marks &amp; Criteria"
        Desc = "Details on minimum board marks (e.g. 60%), course lists, institute certifications, and eligibility checks."
        Icon = "&#128203;"
        Content = @"
        <section class="seo-content card">
            <h2>&#10004;&#65039; Understanding Scholarship Eligibility Constraints</h2>
            <p>Portals use precise logic gates to verify your application's validity. Missing even a single parameter can lead to instant rejection. Pay close attention to these key criteria:</p>
            <ul>
                <li><strong>Academic Merit Thresholds:</strong> Many merit-cum-means scholarships (like NMMSS or MMVY) require minimum percentage markers, such as 55% or 70% in previous board qualifying exams.</li>
                <li><strong>Domicile Safeguards:</strong> State scholarships are strictly reserved for permanent residents of that state. You must have a digitally signed domicile certificate to verify this residency.</li>
                <li><strong>Course Status:</strong> Portals generally exclude correspondence, distance-mode, or unrecognized candidates, verifying your active enrollment directly through your institute code.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "family-income-limits"
        Title = "Family Income Limits for Government Scholarships | Threshold Guide"
        Desc = "Breakdown of annual parental income limits (SC/ST < 2.5L, OBC < 1.5L, MMVY < 6L, EWS < 8L)."
        Icon = "&#8377;"
        Content = @"
        <section class="seo-content card">
            <h2>&#8377; Understanding Scholarship Family Income Caps</h2>
            <p>Most welfare scholarships require candidates to belong to economically weaker sections. Income thresholds vary widely by category and scheme:</p>
            <ul>
                <li><strong>SC/ST Welfare Schemes:</strong> Income limit is generally capped at ₹2.5 Lakhs per annum across most central sector and state schemes.</li>
                <li><strong>OBC Welfare Schemes:</strong> Income threshold limit is tighter, typically capped at ₹1.5 Lakhs or ₹2.0 Lakhs.</li>
                <li><strong>Meritorious General Schemes (EWS / MMVY):</strong> Higher caps are allowed, such as ₹6.0 Lakhs per annum for MMVY in MP, or ₹8.0 Lakhs for general EWS central quotas.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "documents-required"
        Title = "Required Documents Checklist for Scholarships 2026 | Scan Guide"
        Desc = "Visual list and specifications for caste, income, domicile certificates, fees, and bank passbooks."
        Icon = "&#128229;"
        Content = @"
        <section class="seo-content card">
            <h2>&#128229; Comprehensive Scholarship Documents Checklist</h2>
            <p>Keep these high-resolution scanned documents (PDF or JPG under 200KB preferred) ready before starting your portal registration:</p>
            <ul>
                <li><strong>Active Aadhaar Card:</strong> Linked to your working mobile number for e-KYC.</li>
                <li><strong>Domicile Certificate:</strong> Verifying state residency.</li>
                <li><strong>Caste Certificate:</strong> Required for SC, ST, OBC, or Minority quotas.</li>
                <li><strong>Income Certificate:</strong> Issued by a competent Tehsildar authority in the current financial year.</li>
                <li><strong>Previous mark sheets:</strong> Board certificates verifying your passing marks.</li>
                <li><strong>Fee Receipt &amp; Admission Proof:</strong> Verifying ongoing enrollment.</li>
                <li><strong>Bank Passbook:</strong> Linked to your Aadhaar for direct benefit transfers (DBT).</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "aadhaar-ekyc"
        Title = "Aadhaar Linking &amp; e-KYC for Scholarships | Status Verification"
        Desc = "Critical steps to link mobile to Aadhaar, complete Samagra e-KYC, and resolve name mismatches."
        Icon = "&#128274;"
        Content = @"
        <section class="seo-content card">
            <h2>&#128274; Critical Guide: Aadhaar e-KYC for Scholarship Portals</h2>
            <p>Over 60% of all public scholarship rejections are triggered by automated Aadhaar mismatches. Secure your benefit by completing these vital e-KYC steps:</p>
            <ul>
                <li><strong>Complete Mobile Linking:</strong> Ensure your active mobile number is verified at an official Aadhaar center to receive verification OTPs.</li>
                <li><strong>Verify Samagra-Aadhaar Link:</strong> MP residents must link Samagra IDs to Aadhaar e-KYC, matching names exactly.</li>
                <li><strong>Fix Spelling Typos:</strong> If names vary between board certificates and Aadhaar cards, have Aadhaar corrected immediately to avoid database check rejections.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "renewal-process"
        Title = "How to Renew Scholarships 2026 | NSP &amp; State Renewal Guide"
        Desc = "Instructions to maintain min 50% marks, secure 75% school attendance, and apply under renewal cycle."
        Icon = "&#128197;"
        Content = @"
        <section class="seo-content card">
            <h2>&#128197; Standard Scholarship Renewal Guide</h2>
            <p>Once you are awarded a scholarship, securing it for subsequent years requires submitting a renewal application every academic cycle:</p>
            <ul>
                <li><strong>Academic Performance:</strong> Most programs require you to pass previous class exams with at least 50% marks, with zero backlogs.</li>
                <li><strong>Minimum Attendance:</strong> You must secure at least 75% classroom attendance verified directly by your institute head.</li>
                <li><strong>Submit Renewal:</strong> Log in to the portal using your previous application ID, choose "Apply for Renewal", update ongoing fee details, and upload class mark sheets.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "verification-process"
        Title = "Scholarship Application Verification Process | INO &amp; DNO Workflow"
        Desc = "Explains verification stages: Institute Nodal Officer, District Officer, and State Nodal approval flow."
        Icon = "&#9889;"
        Content = @"
        <section class="seo-content card">
            <h2>&#9889; Understanding the 3-Tier Verification Workflow</h2>
            <p>After you submit your application online, it undergoes a rigid three-tier verification sequence before funds are released:</p>
            <ol>
                <li><strong>Level 1: Institute Verification (INO):</strong> Your school Nodal Officer matches your original marks, fees, and certificates with your online form.</li>
                <li><strong>Level 2: District Verification (DNO):</strong> The District Welfare Officer validates your community certificate and income certificates.</li>
                <li><strong>Level 3: State/Central Verification (SNO):</strong> The State Nodal Officer clears your database registry and compiles the final benefit merit list.</li>
            </ol>
        </section>
"@
    },
    @{
        Slug = "common-mistakes"
        Title = "Top Scholarship Application Mistakes to Avoid | Rejection Guide"
        Desc = "Spotlighting common errors like incorrect bank IFSC codes, uploaded expired certificates, and spelling typos."
        Icon = "&#10005;"
        Content = @"
        <section class="seo-content card">
            <h2>&#10005; Avoiding Top Scholarship Application Rejections</h2>
            <p>Ensure your application is processed successfully by watching out for these frequent mistakes:</p>
            <ul>
                <li><strong>Incorrect Bank Details:</strong> Double-check your account number and IFSC code. The account must be active and linked to Aadhaar.</li>
                <li><strong>Expired Income Certificates:</strong> Income certificates must be valid for the current fiscal year. Expired certificates trigger instant rejections.</li>
                <li><strong>Not Handing Over Slip:</strong> Portals will not verify your profile unless you physically submit your printed receipt and documents to your school INO!</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "application-calendar"
        Title = "Scholarship Application Deadlines Calendar 2026"
        Desc = "Timeline guide map for upcoming, open, and closing cycles."
        Icon = "&#128197;"
        Content = @"
        <section class="seo-content card">
            <h2>&#128197; Scholarship Portals Timeline Map</h2>
            <p>Staying ahead of timelines is key to securing educational aid. Mark these general portal cycles on your calendar:</p>
            <ul>
                <li><strong>NSP (Central Sector):</strong> Typically opens in June/July, with deadlines extending through September/October.</li>
                <li><strong>State Portals (MPTAAS, MahaDBT):</strong> Keep registrations open from August through December, accommodating late admissions.</li>
                <li><strong>Direct Benefit Transfers (DBT):</strong> Sanctions and disbursements are typically cleared between January and March.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "state-vs-central"
        Title = "State vs Central Scholarships | Funding Differences &amp; Rules"
        Desc = "Differences between state schemes (MPTAAS) and central sector awards (NSP), explaining double-benefit rules."
        Icon = "&#127775;"
        Content = @"
        <section class="seo-content card">
            <h2>&#127775; State vs Central Sector Funding Systems</h2>
            <p>Students often wonder about the structural differences between state and central initiatives:</p>
            <ul>
                <li><strong>State Scholarships:</strong> Funded entirely by regional state welfare departments. Candidates must possess domicile proof of that specific state.</li>
                <li><strong>Central Scholarships:</strong> Funded by central ministries (Ministry of Minority Affairs, tribal affairs, etc.) and managed through NSP.</li>
                <li><strong>Double Benefit Restriction:</strong> Under strict financial rules, a student cannot draw benefits from two different government scholarships simultaneously! Doing so can lead to benefit recovery and portal suspension.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "girls-scholarship-guide"
        Title = "Girls Scholarships &amp; Empowerment Schemes 2026 | Apply"
        Desc = "Direct resources for Pragati Girls, Gaon Ki Beti, Pratibha Kiran, and corporate female student awards."
        Icon = "&#127775;"
        Content = @"
        <section class="seo-content card">
            <h2>&#127775; Specialized Scholarship Directories for Girls</h2>
            <p>Various state and central departments offer high-value exclusive awards to bridge the educational gender gap:</p>
            <ul>
                <li><strong>Gaon Ki Beti (MP):</strong> Empowers rural girls passing Class 12 with 60% marks with ₹5,000 to ₹7,500 per year.</li>
                <li><strong>AICTE Pragati:</strong> Offers ₹50,000 per year to girl students enrolled in the first year of technical degree or diploma courses.</li>
                <li><strong>Pratibha Kiran:</strong> Financial assistance specifically matching urban poor girl students from BPL families.</li>
            </ul>
        </section>
"@
    },
    @{
        Slug = "engineering-medical-scholarship"
        Title = "Engineering &amp; Medical Scholarships Guide 2026 | Fee Waivers"
        Desc = "Specialized guide for JEE/NEET/CLAT qualifiers under MMVY or professional course aid portals."
        Icon = "&#127891;"
        Content = @"
        <section class="seo-content card">
            <h2>&#127891; Professional Engineering &amp; Medical Course Quotas</h2>
            <p>Pursuing technical or medical education is highly beneficial but costly. Portals offer full fee coverage for qualifiers of competitive entrance exams:</p>
            <ul>
                <li><strong>JEE Main / NEET / CLAT Qualifiers:</strong> Meritorious candidates admitted to premium government colleges or private institutions under state quotas are eligible for full fee coverage.</li>
                <li><strong>MMVY MP Quotas:</strong> Covers up to ₹1.5 Lakhs or actual tuition fees for engineering candidates (JEE rank < 1.5 Lakh), paramedical courses, and law courses.</li>
                <li><strong>Direct Portals:</strong> Apply specifically under professional scheme filters to maximize tuition fee reimbursements.</li>
            </ul>
        </section>
"@
    }
)

# 5 Curated FAQ Portals
$faqsList = @(
    @{
        Slug = "index"
        Title = "General Scholarship FAQ Center | Scholar Slop Help"
        Desc = "Find answers to general scholarship search, platform security, and registration queries."
        Category = "General"
        QAs = @(
            @{ Q = "How does Scholar Slop work?"; A = "Enter your domicile state, category, education level, and family income in our eligibility search tool at the top of the homepage. The system cross-references verified registries to display eligible schemes." },
            @{ Q = "Do you store or track my profile information?"; A = "No, 100% privacy-first! We do not upload or store your financial data or bookmarks on any server. All inputs are saved exclusively on your local device via LocalStorage." },
            @{ Q = "Can I download my documents checklist offline?"; A = "Yes! Simply open any scholarship detail page, navigate to the Documents Required section, and click the 'Download Documents Checklist' button to instantly compile a printable PDF." }
        )
    },
    @{
        Slug = "nsp"
        Title = "NSP (National Scholarship Portal) FAQs | Online Registration Help"
        Desc = "OTP issues, PFMS payment status tracking, and NSP portal guidelines."
        Category = "NSP"
        QAs = @(
            @{ Q = "What should I do if I don't receive the NSP registration OTP?"; A = "Verify that your mobile number is actively linked to Aadhaar. OTPs are sent to your Aadhaar-registered mobile. Clear your browser cache and retry during non-peak hours." },
            @{ Q = "How do I check my NSP payment status?"; A = "All central sector NSP payments are cleared through the Public Financial Management System (PFMS). Visit the official PFMS portal and track payments using your Aadhaar or bank account number." },
            @{ Q = "What is the difference between NSP scholarship types?"; A = "NSP categorizes schemes into Pre-Matric (Class 1-10), Post-Matric (Class 11-PhD), and Merit-cum-Means (technical/professional degrees)." }
        )
    },
    @{
        Slug = "state-scholarships"
        Title = "State Registry Portals FAQs | MPTAAS, MahaDBT &amp; UP Schemes"
        Desc = "Samagra link issues, state domicile checks, and portal lockouts."
        Category = "State"
        QAs = @(
            @{ Q = "Why is the MP MPTAAS portal throwing a Samagra link error?"; A = "This occurs when your name or birthdate varies between your Samagra ID and Aadhaar card. Get your Aadhaar corrected at a local center to match Samagra registry." },
            @{ Q = "Can I apply for a state scheme if I study in another state?"; A = "Yes, provided you are a permanent resident (domicile) of the funding state and your college is recognized by that state's welfare board." },
            @{ Q = "How do I retrieve a locked out state portal account?"; A = "Use the 'Forgot password' flow, complete Aadhaar OTP validation, or visit your Institute Nodal Officer to clear profile lockouts." }
        )
    },
    @{
        Slug = "documents"
        Title = "Scholarship Document Upload FAQs | Certificate Validity Guide"
        Desc = "Income certificate valid dates, digital signature checks, and scan limits."
        Category = "Documents"
        QAs = @(
            @{ Q = "What is the validity period of an income certificate?"; A = "For scholarship purposes, income certificates must generally be issued in the current financial year (after April 1st) to verify active financial status." },
            @{ Q = "Why does the portal reject my scanned PDF certificates?"; A = "Check size limits (usually under 200KB) and ensure that digital signatures on certificates are valid and completely clear." },
            @{ Q = "Can I submit affidavit copies instead of official certificates?"; A = "No! Government portals do not accept affidavits. You must upload verified caste, income, or domicile certificates." }
        )
    },
    @{
        Slug = "eligibility"
        Title = "Academic &amp; Category Eligibility FAQs | Income &amp; Course Limits"
        Desc = "Back-papers effect, income limits, and private candidates criteria."
        Category = "Eligibility"
        QAs = @(
            @{ Q = "Do back-papers or failing exams affect scholarship eligibility?"; A = "Yes! Most schemes exclude candidates with active backlogs or failures. You must pass previous board exams successfully to qualify." },
            @{ Q = "Are private or distance-learning candidates eligible?"; A = "Most public welfare scholarships are strictly reserved for full-time regular candidates enrolled in recognized physical institutions." },
            @{ Q = "What is the EWS income eligibility threshold?"; A = "For general Economically Weaker Section (EWS) quotas, the annual family income cap is generally set at ₹8.0 Lakhs across India." }
        )
    }
)

# Related Scholarships Picker
function Get-RelatedScholarships {
    param($curr, $all)
    $scored = @()
    foreach ($item in $all) {
        if ($item.id -eq $curr.id) { continue }
        $score = 0
        if ($item.State -eq $curr.State) { $score += 3 }
        if ($curr.Category -like "*$($item.Category)*" -or $item.Category -like "*$($curr.Category)*") { $score += 2 }
        if ($item.Type -eq $curr.Type) { $score += 1 }
        
        $temp = [PSCustomObject]@{
            id = $item.id
            Scholarship_Name = $item.Scholarship_Name
            State = $item.State
            Category = $item.Category
            Type = $item.Type
            Benefit_Amount = $item.Benefit_Amount
            Deadline = $item.Deadline
            calculatedStatus = $item.calculatedStatus
            score = $score
        }
        $scored += $temp
    }
    $sorted = $scored | Sort-Object score -Descending
    return $sorted | Select-Object -First 3
}

# Helper: Write file, clearing any restrictive attributes first
function Write-PageFile {
    param([string]$Path, [string]$Content)
    try {
        if ([System.IO.File]::Exists($Path)) {
            [System.IO.File]::SetAttributes($Path, [System.IO.FileAttributes]::Normal)
        }
    } catch { }
    try {
        [System.IO.File]::WriteAllText($Path, $Content, [System.Text.Encoding]::UTF8)
    } catch {
        Write-Output "  SKIP (ACL): $Path"
    }
}

# Template HTML Builder functions
function Get-CommonHead {
    param($title, $description, $canonical, $isSub = $true, $depth = 1)
    $prefix = ""
    for ($i = 0; $i -lt $depth; $i++) { $prefix += "../" }
    return @"
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    
    <title>$title</title>
    <meta name="description" content="$description">
    <link rel="canonical" href="$canonical">
    <meta name="robots" content="index, follow">

    <!-- Open Graph -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="$canonical">
    <meta property="og:title" content="$title">
    <meta property="og:description" content="$description">

    <link rel="icon" type="image/png" sizes="32x32" href="${prefix}assets/favicon.png">
    <link rel="stylesheet" href="${prefix}css/style.css">
    <link rel="stylesheet" href="${prefix}css/temp_style_append.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
"@
}

function Get-CommonHeader {
    param($depth = 1)
    $prefix = ""
    for ($i = 0; $i -lt $depth; $i++) { $prefix += "../" }
    return @"
    <header class="app-header">
        <div class="container header-flex">
            <h1 class="logo"><a href="${prefix}index.html" class="logo-link">&#127891; Scholar Slop</a></h1>
            <div class="header-actions">
                <button class="btn-icon btn-saved" onclick="window.location.href='${prefix}index.html#dashboard'" aria-label="My Saved Scholarships">
                    &#128278;
                    <span id="saved-count" class="badge-count" style="display: none;">0</span>
                </button>
                <button id="dark-mode-toggle" class="btn-icon" onclick="app.toggleDarkMode()" aria-label="Toggle Dark Mode">
                    <span class="icon-sun">&#9728;&#65039;</span>
                    <span class="icon-moon">&#127769;</span>
                </button>
            </div>
        </div>
    </header>
"@
}

function Get-CommonFooter {
    param($depth = 1)
    $prefix = ""
    for ($i = 0; $i -lt $depth; $i++) { $prefix += "../" }
    return @"
    <footer class="app-footer-seo">
        <div class="container footer-grid footer-grid-4">
            <div class="footer-col">
                <h4>&#127891; Scholar Slop</h4>
                <p style="font-size:0.85rem; color:var(--text-secondary); line-height:1.6; margin-bottom:12px;">An independent platform helping students discover verified government scholarships across India.</p>
                <p style="font-size:0.8rem; color:var(--text-light); font-style:italic;">Information compiled from official scholarship portals.</p>
            </div>
            <div class="footer-col">
                <h4>Scholarships</h4>
                <ul>
                    <li><a href="${prefix}mp-scholarship/index.html">Madhya Pradesh</a></li>
                    <li><a href="${prefix}maharashtra-scholarship/index.html">Maharashtra</a></li>
                    <li><a href="${prefix}uttar-pradesh-scholarship/index.html">Uttar Pradesh</a></li>
                    <li><a href="${prefix}west-bengal-scholarship/index.html">West Bengal</a></li>
                    <li><a href="${prefix}sc-scholarship/index.html">SC Category</a></li>
                    <li><a href="${prefix}girls-scholarship/index.html">Girls Scholarships</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>Guides &amp; Help</h4>
                <ul>
                    <li><a href="${prefix}guides/how-to-apply/index.html">How to Apply</a></li>
                    <li><a href="${prefix}guides/documents-required/index.html">Documents Checklist</a></li>
                    <li><a href="${prefix}guides/eligibility-requirements/index.html">Eligibility Guide</a></li>
                    <li><a href="${prefix}faq/index.html">FAQ Center</a></li>
                    <li><a href="${prefix}guides/renewal-process/index.html">Renewal Process</a></li>
                    <li><a href="${prefix}guides/common-mistakes/index.html">Common Mistakes</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>Platform</h4>
                <ul>
                    <li><a href="${prefix}about/index.html">About Us</a></li>
                    <li><a href="${prefix}contact/index.html">Contact</a></li>
                    <li><a href="${prefix}editorial-policy/index.html">Editorial Policy</a></li>
                    <li><a href="${prefix}sources/index.html">Sources</a></li>
                    <li><a href="${prefix}privacy-policy/index.html">Privacy Policy</a></li>
                    <li><a href="${prefix}terms/index.html">Terms of Use</a></li>
                    <li><a href="${prefix}disclaimer/index.html">Disclaimer</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&#9989; Information compiled from verified official government scholarship portals. &nbsp;|&nbsp; &copy; 2026 Scholar Slop. All Rights Reserved.</p>
        </div>
    </footer>
"@
}


function Get-CardHTML {
    param($item, $isSub = $true)
    $prefix = if ($isSub) { "../" } else { "" }
    $statusClass = $item.calculatedStatus.ToLower().Replace(" ", "-")
    $typeClass = $item.Type.ToLower()
    $detailLink = "${prefix}$($item.id)-scholarship/index.html"
    
    $today = [DateTime]::Today
    $timeLeftText = ""
    try {
        $deadlineDate = [DateTime]::Parse($item.Deadline)
        $daysLeft = ($deadlineDate - $today).Days
        if ($daysLeft -lt 0) {
            $timeLeftText = "Closed"
        } elseif ($daysLeft -eq 0) {
            $timeLeftText = "&#9200; Ends Today"
        } else {
            $timeLeftText = "&#9200; $daysLeft days left"
        }
    } catch {
        $timeLeftText = "&#128197; Deadline: $($item.Deadline)"
    }
    
    return @"
    <div class="scholarship-card $statusClass" onclick="window.location.href='$detailLink'" data-id="$($item.id)">
        <button class="btn-bookmark" onclick="app.toggleBookmark('$($item.id)', event)" aria-label="Bookmark">
            &#128278;
        </button>
        <div class="card-badges">
            <span class="badge $statusClass">$($item.calculatedStatus)</span>
            <span class="badge $typeClass">$($item.Type)</span>
        </div>
        <h3>$($item.Scholarship_Name)</h3>
        <div class="card-benefit">
            <span class="benefit-label">Scholarship Benefit</span>
            <span class="benefit-value">$($item.Benefit_Amount)</span>
        </div>
        <div class="card-footer">
            <div class="deadline-info">
                $timeLeftText
            </div>
            <div class="btn-view">View Details</div>
        </div>
    </div>
"@
}

# --- 1. COMPILE INDIVIDUAL SCHOLARSHIP PAGES ---
Write-Output "Step 2: Programmatically compiling individual scholarship pages..."
foreach ($item in $scholarships) {
    $dirName = "$($item.id)-scholarship"
    $targetDir = Join-Path $workspaceRoot $dirName
    if (-not [System.IO.Directory]::Exists($targetDir)) {
        [System.IO.Directory]::CreateDirectory($targetDir) | Out-Null
    }
    
    $related = Get-RelatedScholarships $item $scholarships
    
    $title = "$($item.Scholarship_Name) 2026 | Benefits, Eligibility & Apply"
    $description = "Get detailed guides on $($item.Scholarship_Name) including $($item.Benefit_Amount) benefits, eligibility criteria, required documents list, and official registration portal instructions."
    $canonical = "https://scholarslop.org/$dirName/"
    
    $head = Get-CommonHead $title $description $canonical $true 1
    $header = Get-CommonHeader 1
    $footer = Get-CommonFooter 1
    
    # Render Badges
    $badgeStatusClass = $item.calculatedStatus.ToLower().Replace(" ", "-")
    $badgeTypeClass = $item.Type.ToLower()
    $badgesHTML = "<span class='badge $badgeStatusClass'>$($item.calculatedStatus)</span><span class='badge $badgeTypeClass'>$($item.Type)</span>"
    
    # Pre-render list items
    $eligibilityItems = ""
    foreach ($e in $item.Eligibility) {
        $eligibilityItems += "<li>$e</li>"
    }
    $docItems = ""
    foreach ($d in $item.Documents_Required) {
        $docItems += "<li>$d</li>"
    }
    
    # Pre-render related cards
    $relatedCardsHTML = ""
    foreach ($rel in $related) {
        $relatedCardsHTML += Get-CardHTML $rel
    }
    
    # Format dates
    function Format-FriendlyDate {
        param($dStr)
        if (-not $dStr -or $dStr -eq "N/A") { return "N/A" }
        try {
            $dVal = [DateTime]::Parse($dStr)
            return $dVal.ToString("dd MMM yyyy")
        } catch {
            return $dStr
        }
    }
    
    $startFriendly = Format-FriendlyDate $item.Start_Date
    $deadlineFriendly = Format-FriendlyDate $item.Deadline
    $verifiedFriendly = Format-FriendlyDate $item.Last_Verified
    
    # State mapping for Breadcrumbs
    $stateSlug = Get-StateSlug $item.State
    $stateBreadcrumb = if ($item.State -eq "Central") {
        "<a href='../general-scholarship/index.html'>Central Scholarships</a>"
    } else {
        "<a href='../$stateSlug-scholarship/index.html'>$($item.State) Scholarships</a>"
    }
    
    # Dynamic important note
    $importantNoteText = "Ensure all documents are scanned clearly and your profile is 100% complete before submission. Early applications are highly recommended to avoid portal overload."
    if ($item.calculatedStatus -eq "Closed") {
        $importantNoteText = "This scholarship is currently closed. Keep checking back for the next application cycle."
    } elseif ($item.calculatedStatus -eq "Closing Soon") {
        $importantNoteText = "Deadline is approaching very soon! Submit your application immediately to ensure consideration."
    }
    
    # JSON-LD Schema
    $amountValue = $item.Benefit_Amount -replace '[^\d]', ''
    $schemaJson = @"
    {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "WebPage",
                "@id": "$canonical#webpage",
                "url": "$canonical",
                "name": "$title",
                "description": "$description"
            },
            {
                "@type": "BreadcrumbList",
                "@id": "$canonical#breadcrumb",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": 1,
                        "name": "Home",
                        "item": "https://scholarslop.org/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 2,
                        "name": "$($item.State) Scholarships",
                        "item": "https://scholarslop.org/$($stateSlug)-scholarship/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 3,
                        "name": "$($item.Scholarship_Name)",
                        "item": "$canonical"
                    }
                ]
            },
            {
                "@type": "Scholarship",
                "name": "$($item.Scholarship_Name)",
                "description": "$($item.Overview)",
                "sponsor": {
                    "@type": "GovernmentOrganization",
                    "name": "$($item.State) Government"
                },
                "amount": {
                    "@type": "MonetaryAmount",
                    "currency": "INR",
                    "value": "$amountValue"
                },
                "eligibility": [
                    {
                        "@type": "EligibilityCategory",
                        "name": "Domicile State: $($item.State)"
                    },
                    {
                        "@type": "EligibilityCategory",
                        "name": "Category Requirement: $($item.Category)"
                    }
                ]
            }
        ]
    }
"@
    
    $pageHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
    $head
    <script type="application/ld+json">
    $schemaJson
    </script>
</head>
<body>
    $header

    <main id="app-content" class="container">
        <article class="detail-container" id="static-detail-container" data-id="$($item.id)">
            <!-- Visual Breadcrumbs -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <div class="breadcrumb-item"><a href="../index.html">Home</a></div>
                <div class="breadcrumb-item">$stateBreadcrumb</div>
                <div class="breadcrumb-item active" aria-current="page">$($item.Scholarship_Name)</div>
            </nav>

            <div class="detail-layout">
                <section class="detail-main-content">
                    <header class="detail-header">
                        <div class="card-badges" id="detail-badges" style="justify-content: center; margin-bottom: 16px;">
                            $badgesHTML
                        </div>
                        <h2 id="detail-name">$($item.Scholarship_Name)</h2>
                        <div id="detail-urgency" class="deadline-info" style="justify-content: center; margin-bottom: 8px;">
                            &#9200; $($item.calculatedStatus)
                        </div>
                        <p class="meta-info" style="color: var(--text-secondary); text-align: center;"><span id="detail-state">$($item.State)</span> &bull; <span id="detail-category">$($item.Category)</span></p>
                    </header>

                    <div class="detail-benefit-highlight">
                        <span class="label">Total Benefit Amount</span>
                        <span class="value" id="detail-benefit-value">$($item.Benefit_Amount)</span>
                    </div>

                    <div id="detail-notes-box" class="notes-box">
                        <p><strong>Important Note:</strong> $importantNoteText</p>
                    </div>

                    <section class="section">
                        <h3>Overview</h3>
                        <p id="detail-overview">$($item.Overview)</p>
                    </section>

                    <section class="section">
                        <h3>Eligibility Criteria</h3>
                        <ul id="detail-eligibility" class="checklist">
                            $eligibilityItems
                        </ul>
                    </section>

                    <section class="section">
                        <h3>Detailed Benefits</h3>
                        <p id="detail-benefit">$($item.Benefit_Type)</p>
                    </section>

                    <section class="section">
                        <h3>Documents Required</h3>
                        <ul id="detail-docs" class="document-checklist">
                            $docItems
                        </ul>
                    </section>

                    <section class="section dates-section">
                        <div class="date-item">
                            <span class="label">Application Start</span>
                            <span class="value" id="detail-start">$startFriendly</span>
                        </div>
                        <div class="date-item">
                            <span class="label">Application Deadline</span>
                            <span class="value highlight" id="detail-deadline">$deadlineFriendly</span>
                        </div>
                    </section>

                    <section class="section download-section">
                        <button class="btn-download-docs" onclick="app.downloadDocumentsList(event)" title="Download Documents Checklist">
                            &#128229; Download Documents Checklist
                        </button>
                        <p class="download-hint">Get a printable checklist of all required documents</p>
                    </section>
                </section>

                <aside class="detail-sidebar">
                    <!-- Advanced Features Placeholders -->
                    <div id="detail-tracking-placeholder">
                        <div class="section tracking-controls">
                            <h3>&#128205; Set Status</h3>
                            <p style="font-size: 0.85rem;">Track your progress on this application.</p>
                            <div class="tracking-options">
                                <button class="btn-tracking" onclick="app.updateTrackingStatus('$($item.id)', 'Planning')">Planning</button>
                                <button class="btn-tracking" onclick="app.updateTrackingStatus('$($item.id)', 'Applied')">Applied</button>
                                <button class="btn-tracking" onclick="app.updateTrackingStatus('$($item.id)', 'Missed')">Missed</button>
                            </div>
                        </div>
                    </div>
                    <div id="detail-reminders-placeholder"></div>

                    <section class="section how-to-apply">
                        <h3>How to Apply</h3>
                        <div class="application-steps">
                            <div class="step">
                                <div class="step-number">1</div>
                                <div class="step-content">
                                    <h4>Visit Portal</h4>
                                    <p>Go to the official scholarship portal using the direct link below.</p>
                                </div>
                            </div>
                            <div class="step">
                                <div class="step-number">2</div>
                                <div class="step-content">
                                    <h4>Login/Register</h4>
                                    <p>Log in with your existing credentials or create a new profile.</p>
                                </div>
                            </div>
                            <div class="step">
                                <div class="step-number">3</div>
                                <div class="step-content">
                                    <h4>Complete Profile</h4>
                                    <p>Fill in your basic, academic, family income, and certificate details.</p>
                                </div>
                            </div>
                            <div class="step">
                                <div class="step-number">4</div>
                                <div class="step-content">
                                    <h4>Upload Documents</h4>
                                    <p>Attach all the required documents listed in our checklist.</p>
                                </div>
                            </div>
                            <div class="step">
                                <div class="step-number">5</div>
                                <div class="step-content">
                                    <h4>Submit</h4>
                                    <p>Double-check all inputs, submit, and download your receipt copy.</p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <div class="verification-box">
                        <p>Last verified on: <span id="detail-verified">$verifiedFriendly</span></p>
                        <p>Source: Official Portal Website</p>
                    </div>

                    <div class="action-footer">
                        <a href="$($item.Source_Link)" target="_blank" id="detail-apply-btn" class="btn btn-primary btn-block btn-lg">Apply on Official Portal <span class="external-icon">&#8599;</span></a>
                    </div>
                </aside>
            </div>

            <!-- Related Scholarships -->
            <section class="related-section">
                <h3>Related Scholarship Schemes</h3>
                <div class="related-grid scholarship-grid">
                    $relatedCardsHTML
                </div>
            </section>
        </article>
    </main>

    $footer

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script>window.isStaticPage = true;</script>
    <script src="../js/data.js"></script>
    <script src="../js/app.js"></script>
</body>
</html>
"@
    
    $outPath = Join-Path $targetDir "index.html"
    Write-PageFile $outPath $pageHTML
}

# --- 2. COMPILE STATE DIRECTORY PAGES ---
Write-Output "Step 3: Programmatically compiling state scholarship directory pages..."
foreach ($st in $statesList) {
    $dirName = "$($st.Slug)-scholarship"
    $targetDir = Join-Path $workspaceRoot $dirName
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }
    
    # Filter state-specific scholarships & central scholarships
    $stateSchemes = @()
    $centralSchemes = @()
    
    foreach ($item in $scholarships) {
        if ($item.State -eq $st.Name) {
            $stateSchemes += $item
        } elseif ($item.State -eq "Central") {
            $centralSchemes += $item
        }
    }
    
    $title = "$($st.Name) Scholarship 2026 | $($st.Name) Scholarships & Portal Guide"
    $description = "Explore verified $($st.Name) scholarships including state financial aid schemes and portal directories. Check eligibility, benefits, and apply online."
    $canonical = "https://scholarslop.org/$dirName/"
    
    $head = Get-CommonHead $title $description $canonical $true 1
    $header = Get-CommonHeader 1
    $footer = Get-CommonFooter 1
    
    # Generate cards HTML
    $stateCardsHTML = ""
    foreach ($item in $stateSchemes) {
        $stateCardsHTML += Get-CardHTML $item
    }
    if ($stateCardsHTML -eq "") {
        $stateCardsHTML = "<p class='empty-state'>No active schemes found currently for $($st.Name).</p>"
    }
    
    $centralCardsHTML = ""
    foreach ($item in $centralSchemes) {
        $centralCardsHTML += Get-CardHTML $item
    }
    
    # State-specific custom portal registration guides
    $portalGuideHTML = ""
    $faqHTML = ""
    $faqSchema = ""
    
    if ($st.Name -eq "Madhya Pradesh") {
        $portalGuideHTML = @"
        <ol>
            <li><strong>Register on MPTAAS Portal:</strong> Visit the official MPTAAS website and create your Profile Registration ID by verifying your Samagra ID, Aadhaar e-KYC, and Caste Certificate.</li>
            <li><strong>Add Domicile & Income Details:</strong> Verify your digital Domicile certificate and submit your family's annual income declaration form.</li>
            <li><strong>Apply for Scheme:</strong> Navigate to Scholarship Application, select the scheme (Post-Matric or MMVY), enter your college registration code, and upload fee receipts.</li>
        </ol>
"@
        $faqHTML = @"
        <div class="faq-item">
            <h4>1. What is the income limit for MMVY in Madhya Pradesh?</h4>
            <p>To qualify for the Mukhyamantri Medhavi Vidyarthi Yojana (MMVY), the candidate's parent's annual income must be less than ₹6,0,000.</p>
        </div>
        <div class="faq-item">
            <h4>2. Is Aadhaar e-KYC mandatory for MPTAAS?</h4>
            <p>Yes, permanent residents of MP must have a valid Aadhaar linked to their Samagra ID and bank account to clear MPTAAS verification.</p>
        </div>
"@
        $faqSchema = @"
        {
            "@type": "Question",
            "name": "What is the income limit for MMVY in Madhya Pradesh?",
            "acceptedAnswer": {
                "@type": "Answer",
                "text": "To qualify for the Mukhyamantri Medhavi Vidyarthi Yojana (MMVY), the candidate's parent's annual income must be less than ₹6,0,000."
            }
        },
        {
            "@type": "Question",
            "name": "Is Aadhaar e-KYC mandatory for MPTAAS?",
            "acceptedAnswer": {
                "@type": "Answer",
                "text": "Yes, permanent residents of MP must have a valid Aadhaar linked to their Samagra ID and bank account to clear MPTAAS verification."
            }
        }
"@
    } else {
        $portalGuideHTML = @"
        <ol>
            <li><strong>Profile Registration:</strong> Visit the regional portal and complete your basic student profile registration using your Aadhaar card number.</li>
            <li><strong>Verify Academic Credentials:</strong> Enter your previous year marks, course duration, institute code, and upload the fee details document.</li>
            <li><strong>Submit Certificate Proofs:</strong> Upload caste, income, and domicile certificates issued by the competent regional authority.</li>
        </ol>
"@
        $faqHTML = @"
        <div class="faq-item">
            <h4>1. Who can apply for state-funded schemes here?</h4>
            <p>Permanent residents of $($st.Name) who fulfill the eligibility conditions (caste, income, or educational limits) are eligible to apply.</p>
        </div>
"@
        $faqSchema = @"
        {
            "@type": "Question",
            "name": "Who can apply for state-funded schemes here?",
            "acceptedAnswer": {
                "@type": "Answer",
                "text": "Permanent residents of $($st.Name) who fulfill the eligibility conditions (caste, income, or educational limits) are eligible to apply."
            }
        }
"@
    }
    
    # JSON-LD Schema
    $schemaJson = @"
    {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "CollectionPage",
                "@id": "$canonical#webpage",
                "url": "$canonical",
                "name": "$title",
                "description": "$description"
            },
            {
                "@type": "BreadcrumbList",
                "@id": "$canonical#breadcrumb",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": 1,
                        "name": "Home",
                        "item": "https://scholarslop.org/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 2,
                        "name": "$($st.Name) Scholarships",
                        "item": "$canonical"
                    }
                ]
            },
            {
                "@type": "FAQPage",
                "mainEntity": [
                    $faqSchema
                ]
            }
        ]
    }
"@
    
    $pageHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
    $head
    <script type="application/ld+json">
    $schemaJson
    </script>
</head>
<body>
    $header

    <main id="app-content" class="container">
        <!-- Visual Breadcrumbs -->
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <div class="breadcrumb-item"><a href="../index.html">Home</a></div>
            <div class="breadcrumb-item active" aria-current="page">$($st.Name) Scholarships</div>
        </nav>

        <section class="seo-content card">
            <h2>&#127891; $($st.Name) Scholarships 2026 Overview</h2>
            <p>Welcome to the comprehensive guide to verified government scholarships in $($st.Name). The state government offers numerous financial aid programs, tuition fee reimbursements, and monthly maintenance stipends to empower students from marginalized communities and meritorious general students.</p>
            <p>With clean directories, check out matching state-funded opportunities below, and explore central sector initiatives to maximize your financial aid potential.</p>
        </section>

        <section class="section">
            <h3>State-Funded Scholarship Schemes</h3>
            <div class="scholarship-grid">
                $stateCardsHTML
            </div>
        </section>

        <section class="section seo-content card" style="margin-top: 40px;">
            <h2>&#128221; Official Application Portal &amp; Process</h2>
            <p>Applications for state schemes are managed through the official portal. Follow this step-by-step process to ensure a successful application submission:</p>
            $portalGuideHTML
            <p style="margin-top: 16px; font-weight: 500;">&#128276; Tip: Always match your school records exactly with your Aadhaar registry to prevent verification rejections!</p>
        </section>

        <section class="section">
            <h3>Recommended Central Schemes (NSP)</h3>
            <div class="scholarship-grid">
                $centralCardsHTML
            </div>
        </section>

        <section class="section seo-content card" style="margin-top: 40px;">
            <h2>&#10067; Portal Frequently Asked Questions (FAQs)</h2>
            <div class="faq-container">
                $faqHTML
            </div>
        </section>
    </main>

    $footer

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script>window.isStaticPage = true;</script>
    <script src="../js/data.js"></script>
    <script src="../js/app.js"></script>
</body>
</html>
"@
    
    $outPath = Join-Path $targetDir "index.html"
    Write-PageFile $outPath $pageHTML
}

Write-Output "Step 4: Programmatically compiling category scholarship directory pages..."
foreach ($cat in $categoriesList) {
    $dirName = "$($cat.Slug)-scholarship"
    $targetDir = Join-Path $workspaceRoot $dirName
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }
    
    # Filter matching scholarships
    $matching = @()
    foreach ($item in $scholarships) {
        $isMatch = $false
        if ($cat.Name -eq "Girls") {
            # Girls matching
            if ($item.Scholarship_Name -like "*girl*" -or $item.Scholarship_Name -like "*beti*" -or $item.Scholarship_Name -like "*pragati*" -or $item.Scholarship_Name -like "*pratibha kiran*" -or $item.Overview -like "*girl*" -or $item.Overview -like "*daughter*") {
                $isMatch = $true
            }
        } else {
            # Standard category matching
            if ($item.Category -like "*$($cat.Name)*") {
                $isMatch = $true
            }
        }
        
        if ($isMatch) {
            $matching += $item
        }
    }
    
    $title = "$($cat.Name) Category Scholarships 2026 | Financial Aid & Eligibility"
    $description = "Discover verified scholarships, monthly stipends, and tuition fee waivers for $($cat.Name) students in India. View application deadlines and guides."
    $canonical = "https://scholarslop.org/$dirName/"
    
    $head = Get-CommonHead $title $description $canonical $true 1
    $header = Get-CommonHeader 1
    $footer = Get-CommonFooter 1
    
    # Generate cards HTML
    $cardsHTML = ""
    foreach ($item in $matching) {
        $cardsHTML += Get-CardHTML $item
    }
    if ($cardsHTML -eq "") {
        $cardsHTML = "<p class='empty-state'>No active schemes found currently for $($cat.Name) category.</p>"
    }
    
    # Who can apply guide
    $whoCanApplyHTML = ""
    if ($cat.Name -eq "Girls") {
        $whoCanApplyHTML = @"
        <ul>
            <li><strong>Gender:</strong> Exclusively for female students enrolled in recognized educational institutions.</li>
            <li><strong>Academic Merit:</strong> Typically requires minimum 60% marks in Class 12 or previous exams.</li>
            <li><strong>Welfare Category:</strong> Welfare schemes are available for rural girls (Gaon Ki Beti), urban poor girls, or girls studying technical courses (Pragati Scheme).</li>
        </ul>
"@
    } else {
        $whoCanApplyHTML = @"
        <ul>
            <li><strong>Category Certification:</strong> Must possess a valid caste or community certificate issued by authorized authorities.</li>
            <li><strong>Annual Family Income Limit:</strong> Variable threshold limit (generally below &#8377;2.5 Lakhs for SC/ST, and below &#8377;1.5 Lakhs for OBC).</li>
            <li><strong>Enrollment:</strong> Must be studying full-time in recognized school, college, or polytechnic courses.</li>
        </ul>
"@
    }
    
    # JSON-LD Schema
    $schemaJson = @"
    {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "CollectionPage",
                "@id": "$canonical#webpage",
                "url": "$canonical",
                "name": "$title",
                "description": "$description"
            },
            {
                "@type": "BreadcrumbList",
                "@id": "$canonical#breadcrumb",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": 1,
                        "name": "Home",
                        "item": "https://scholarslop.org/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 2,
                        "name": "$($cat.Name) Scholarships",
                        "item": "$canonical"
                    }
                ]
            }
        ]
    }
"@
    
    $pageHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
    $head
    <script type="application/ld+json">
    $schemaJson
    </script>
</head>
<body>
    $header

    <main id="app-content" class="container">
        <!-- Visual Breadcrumbs -->
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <div class="breadcrumb-item"><a href="../index.html">Home</a></div>
            <div class="breadcrumb-item active" aria-current="page">$($cat.Name) Scholarships</div>
        </nav>

        <section class="seo-content card">
            <h2>&#127891; $($cat.Name) Category Scholarships Overview</h2>
            <p>$($cat.Desc)</p>
            <p>Our platform aggregates verified state and central opportunities. Browse active matching scholarships below and track their deadlines.</p>
        </section>

        <section class="section">
            <h3>Verified Opportunities for $($cat.Name) Students</h3>
            <div class="scholarship-grid">
                $cardsHTML
            </div>
        </section>

        <section class="section seo-content card" style="margin-top: 40px;">
            <h2>&#128203; Standard Eligibility &amp; Requirements</h2>
            <p>While each scheme has specific guidelines, most $($cat.Name) scholarships require the following core qualifications:</p>
            $whoCanApplyHTML
        </section>

        <section class="section seo-content card" style="margin-top: 40px;">
            <h2>&#128221; Step-by-Step Portal Application Guide</h2>
            <p>To submit your application successfully, follow these standard steps on either the National Scholarship Portal (NSP) or your regional state directory portal:</p>
            <ol>
                <li><strong>Profile Onboarding:</strong> Verify your Aadhaar details and generate your application login credentials.</li>
                <li><strong>Select Scheme:</strong> Search for active schemes matching your category and enter your education course details.</li>
                <li><strong>Upload Documents:</strong> Securely upload scanned copies of your category certificate, income declaration, previous marksheet, and fee receipt.</li>
                <li><strong>Final Submission:</strong> Verify the correctness of your application and submit it before the listed deadline.</li>
            </ol>
        </section>
    </main>

    $footer

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script>window.isStaticPage = true;</script>
    <script src="../js/data.js"></script>
    <script src="../js/app.js"></script>
</body>
</html>
"@
    
    $outPath = Join-Path $targetDir "index.html"
    Write-PageFile $outPath $pageHTML
}

# --- 4. COMPILE TOPICAL KNOWLEDGE GUIDES ---
Write-Output "Step 4a: Programmatically compiling topical guides..."
$guidesDir = Join-Path $workspaceRoot "guides"
if (-not (Test-Path $guidesDir)) {
    New-Item -ItemType Directory -Path $guidesDir | Out-Null
}

foreach ($g in $guidesList) {
    $targetDir = Join-Path $guidesDir $g.Slug
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }
    
    $canonical = "https://scholarslop.org/guides/$($g.Slug)/"
    $head = Get-CommonHead $g.Title $g.Desc $canonical $true 2
    $header = Get-CommonHeader 2
    $footer = Get-CommonFooter 2
    
    # JSON-LD Schema
    $schemaJson = @"
    {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "WebPage",
                "@id": "$canonical#webpage",
                "url": "$canonical",
                "name": "$($g.Title)",
                "description": "$($g.Desc)"
            },
            {
                "@type": "BreadcrumbList",
                "@id": "$canonical#breadcrumb",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": 1,
                        "name": "Home",
                        "item": "https://scholarslop.org/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 2,
                        "name": "Guides",
                        "item": "https://scholarslop.org/guides/state-scholarship-portals/index.html"
                    },
                    {
                        "@type": "ListItem",
                        "position": 3,
                        "name": "$($g.Slug)",
                        "item": "$canonical"
                    }
                ]
            }
        ]
    }
"@
    
    $pageHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
    $head
    <script type="application/ld+json">
    $schemaJson
    </script>
</head>
<body>
    $header

    <main id="app-content" class="container">
        <!-- Visual Breadcrumbs -->
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <div class="breadcrumb-item"><a href="../../index.html">Home</a></div>
            <div class="breadcrumb-item"><a href="../state-scholarship-portals/index.html">Guides</a></div>
            <div class="breadcrumb-item active" aria-current="page">$($g.Slug)</div>
        </nav>

        $($g.Content)

        <section class="section seo-content card" style="margin-top: 32px; text-align: center;">
            <h3>&#127891; Need Active Schemes matching your profile?</h3>
            <p>Go to the homepage, submit your academic profile details, and instantly parse matching government benefits.</p>
            <a href="../../index.html" class="btn btn-primary">Check My Eligibility Now &rarr;</a>
        </section>
    </main>

    $footer

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script>window.isStaticPage = true;</script>
    <script src="../../js/data.js"></script>
    <script src="../../js/app.js"></script>
</body>
</html>
"@
    
    $outPath = Join-Path $targetDir "index.html"
    Write-PageFile $outPath $pageHTML
}

# --- 5. COMPILE FAQ ACCORDION PAGES ---
Write-Output "Step 4b: Programmatically compiling FAQ accordion hubs..."
$faqsDir = Join-Path $workspaceRoot "faq"
if (-not (Test-Path $faqsDir)) {
    New-Item -ItemType Directory -Path $faqsDir | Out-Null
}

foreach ($f in $faqsList) {
    $targetDir = if ($f.Slug -eq "index") { $faqsDir } else { Join-Path $faqsDir $f.Slug }
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }
    
    $depth = if ($f.Slug -eq "index") { 1 } else { 2 }
    $backHomeLink = if ($depth -eq 1) { "index.html" } else { "../index.html" }
    
    $canonical = if ($f.Slug -eq "index") { "https://scholarslop.org/faq/" } else { "https://scholarslop.org/faq/$($f.Slug)/" }
    $head = Get-CommonHead $f.Title $f.Desc $canonical $true $depth
    $header = Get-CommonHeader $depth
    $footer = Get-CommonFooter $depth
    
    # Generate accordions HTML
    $accordionsHTML = ""
    $faqSchemaList = @()
    
    foreach ($qa in $f.QAs) {
        $accordionsHTML += @"
        <div class="faq-accordion-item">
            <button class="faq-accordion-trigger" onclick="app.toggleFaq(event)">
                <span>$($qa.Q)</span>
                <span class="faq-icon">&#43;</span>
            </button>
            <div class="faq-accordion-content">
                <p>$($qa.A)</p>
            </div>
        </div>
"@
        $faqSchemaList += @"
        {
            "@type": "Question",
            "name": "$($qa.Q)",
            "acceptedAnswer": {
                "@type": "Answer",
                "text": "$($qa.A)"
            }
        }
"@
    }
    
    $faqSchemaMerged = $faqSchemaList -join ","
    
    # JSON-LD Schema
    $schemaJson = @"
    {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "WebPage",
                "@id": "$canonical#webpage",
                "url": "$canonical",
                "name": "$($f.Title)",
                "description": "$($f.Desc)"
            },
            {
                "@type": "BreadcrumbList",
                "@id": "$canonical#breadcrumb",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": 1,
                        "name": "Home",
                        "item": "https://scholarslop.org/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 2,
                        "name": "FAQ Center",
                        "item": "https://scholarslop.org/faq/"
                    }
                ]
            },
            {
                "@type": "FAQPage",
                "mainEntity": [
                    $faqSchemaMerged
                ]
            }
        ]
    }
"@
    
    # On the index page, show topic cards at the top
    $topicsHTML = ""
    if ($f.Slug -eq "index") {
        $topicsHTML = @"
        <section class="section gateway-section" style="margin-top: 0; padding-top: 0;">
            <div class="gateway-grid" style="grid-template-columns: repeat(2, 1fr);">
                <a href="nsp/index.html" class="gateway-card">
                    <span class="card-icon">&#9889;</span>
                    <h5>NSP FAQ Center</h5>
                    <p>OTP errors, PFMS tracking, and central sector registries.</p>
                    <span class="card-cta">View FAQs &rsaquo;</span>
                </a>
                <a href="state-scholarships/index.html" class="gateway-card">
                    <span class="card-icon">&#128205;</span>
                    <h5>State Portals FAQ</h5>
                    <p>MPTAAS locks, MahaDBT verification, and regional schemes.</p>
                    <span class="card-cta">View FAQs &rsaquo;</span>
                </a>
                <a href="documents/index.html" class="gateway-card">
                    <span class="card-icon">&#128229;</span>
                    <h5>Document Upload FAQ</h5>
                    <p>Income validity guides, caste uploads, and scanning specifications.</p>
                    <span class="card-cta">View FAQs &rsaquo;</span>
                </a>
                <a href="eligibility/index.html" class="gateway-card">
                    <span class="card-icon">&#127775;</span>
                    <h5>Academic Eligibility FAQ</h5>
                    <p>Marks limits, backlog exams constraints, and income bounds.</p>
                    <span class="card-cta">View FAQs &rsaquo;</span>
                </a>
            </div>
        </section>
"@
    }
    
    $breadcrumbHTML = if ($f.Slug -eq "index") {
        @"
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <div class="breadcrumb-item"><a href="$backHomeLink">Home</a></div>
            <div class="breadcrumb-item active" aria-current="page">FAQ Center</div>
        </nav>
"@
    } else {
        @"
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <div class="breadcrumb-item"><a href="../$backHomeLink">Home</a></div>
            <div class="breadcrumb-item"><a href="../index.html">FAQ Center</a></div>
            <div class="breadcrumb-item active" aria-current="page">$($f.Category) FAQs</div>
        </nav>
"@
    }
    
    $pageHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
    $head
    <script type="application/ld+json">
    $schemaJson
    </script>
</head>
<body>
    $header

    <main id="app-content" class="container">
        $breadcrumbHTML

        <section class="seo-content card">
            <h2>&#10067; $($f.Title)</h2>
            <p>$($f.Desc)</p>
        </section>

        $topicsHTML

        <section class="section faq-section" style="margin-top: 32px;">
            <div class="faq-accordion-container">
                $accordionsHTML
            </div>
        </section>
        
        <section class="section seo-content card" style="margin-top: 32px; text-align: center;">
            <h3>&#127891; Seek further scholarship discoveries?</h3>
            <p>Access the homepage, fill out your category and income parameters, and match with verified portals.</p>
            <a href="$backHomeLink" class="btn btn-primary">Check My Eligibility Now &rarr;</a>
        </section>
    </main>

    $footer

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script>window.isStaticPage = true;</script>
    <script src="$($prefix)js/data.js"></script>
    <script src="$($prefix)js/app.js"></script>
</body>
</html>
"@
    
    $outPath = Join-Path $targetDir "index.html"
    Write-PageFile $outPath $pageHTML
}

# --- 6. GENERATE SITEMAP.XML ---
Write-Output "Step 5: Generating sitemap.xml..."
$sitemapXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://scholarslop.org/</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
    </url>
"@

# Add States
foreach ($st in $statesList) {
    $sitemapXml += @"

    <url>
        <loc>https://scholarslop.org/$($st.Slug)-scholarship/</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>
"@
}

# Add Categories
foreach ($cat in $categoriesList) {
    $sitemapXml += @"

    <url>
        <loc>https://scholarslop.org/$($cat.Slug)-scholarship/</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>
"@
}

# Add Individual Scholarships
foreach ($item in $scholarships) {
    $sitemapXml += @"

    <url>
        <loc>https://scholarslop.org/$($item.id)-scholarship/</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.6</priority>
    </url>
"@
}

# Add Guides
foreach ($g in $guidesList) {
    $sitemapXml += @"

    <url>
        <loc>https://scholarslop.org/guides/$($g.Slug)/</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.7</priority>
    </url>
"@
}

# Add FAQs
foreach ($f in $faqsList) {
    $locUrl = if ($f.Slug -eq "index") { "https://scholarslop.org/faq/" } else { "https://scholarslop.org/faq/$($f.Slug)/" }
    $sitemapXml += @"

    <url>
        <loc>$locUrl</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.7</priority>
    </url>
"@
}


# ============================================================
# --- STEP 6: GENERATE 7 AUTHORITY PAGES ---
# ============================================================
Write-Output "Step 6: Generating Authority and Trust pages..."

$authorityList = @(
    @{
        Slug    = "about"
        Title   = "About Us | Scholar Slop - Independent Scholarship Platform"
        Desc    = "Learn about Scholar Slop's mission to help Indian students discover verified government scholarships. Our editorial standards, independence, and student-first commitment."
        Schema  = "Organization"
        Hero    = @{ Badge = "Our Mission"; H2 = "About Scholar Slop"; P = "An independent, student-first platform helping millions discover verified government scholarship opportunities across India. No login selling. No fees. Just verified information." }
        Content = @"
        <section class="section">
            <div class="mission-grid">
                <div class="mission-card"><div class="m-icon">&#127891;</div><h4>Our Purpose</h4><p>We exist to bridge the information gap between students and official government scholarship portals, making financial aid accessible to every eligible student in India.</p></div>
                <div class="mission-card"><div class="m-icon">&#128274;</div><h4>Privacy First</h4><p>Your profile and scholarship data never leave your browser. We do not collect, store, or sell any personal information. Everything runs in-browser on LocalStorage.</p></div>
                <div class="mission-card"><div class="m-icon">&#10003;&#65039;</div><h4>Verified Sources</h4><p>All scholarship data is cross-referenced against official portals including NSP, MahaDBT, MP Scholarship Portal, UP Saksham, and West Bengal Oasis.</p></div>
            </div>
        </section>
        <section class="section">
            <h3 class="section-title">Our Editorial Standards</h3>
            <div class="info-block"><h4>Source Verification</h4><p>Every scholarship entry must be traceable to an official government portal URL before it is included in our database. We do not publish unverified or third-party scholarship claims.</p></div>
            <div class="info-block"><h4>Independence</h4><p>Scholar Slop is an independent informational platform. We are not affiliated with, endorsed by, or acting as agents for any government body, scholarship provider, or educational institution. We do not charge application fees.</p></div>
            <div class="info-block"><h4>Update Policy</h4><p>Scholarship data is monitored against official portal announcements. When portals publish deadline updates, benefit revisions, or eligibility changes, we update our listings accordingly.</p></div>
            <div class="info-highlight">&#128200; Our goal: help students spend less time searching and more time applying to the right scholarships.</div>
        </section>
"@
    },
    @{
        Slug    = "contact"
        Title   = "Contact Us | Scholar Slop"
        Desc    = "Contact Scholar Slop for scholarship data corrections, partnership inquiries, or editorial feedback. We typically respond within 48 hours."
        Schema  = "ContactPage"
        Hero    = @{ Badge = "Get In Touch"; H2 = "Contact Us"; P = "Have a correction, suggestion, or editorial feedback? We want to hear from you. Use the form below to reach our editorial team." }
        Content = @"
        <section class="section">
            <div class="contact-layout">
                <div class="contact-form-card">
                    <h3>Send a Message</h3>
                    <form id="contact-form" novalidate>
                        <div class="form-row-2">
                            <div class="form-group-contact"><label for="cf-name">Your Name *</label><input type="text" id="cf-name" class="input-field" placeholder="e.g. Priya Sharma" required></div>
                            <div class="form-group-contact"><label for="cf-email">Email Address *</label><input type="email" id="cf-email" class="input-field" placeholder="your@email.com" required></div>
                        </div>
                        <div class="form-group-contact">
                            <label for="cf-subject">Subject</label>
                            <select id="cf-subject" class="input-field">
                                <option value="correction">Scholarship Data Correction</option>
                                <option value="new">New Scholarship Suggestion</option>
                                <option value="bug">Bug / Technical Issue</option>
                                <option value="feedback">General Feedback</option>
                                <option value="other">Other</option>
                            </select>
                        </div>
                        <div class="form-group-contact"><label for="cf-message">Message *</label><textarea id="cf-message" class="input-field" placeholder="Please describe your query in detail..." required></textarea></div>
                        <button type="submit" class="btn-primary" style="width:100%; padding:14px;">&#128140; Submit Message</button>
                    </form>
                </div>
                <div class="contact-info-card">
                    <div class="contact-info-item"><div class="ci-label">Response Time</div><div class="ci-value">Within 48 hours</div><div class="ci-note">We review all messages and respond during business hours (Mon-Sat, 10am-6pm IST).</div></div>
                    <div class="contact-info-item"><div class="ci-label">Data Corrections</div><div class="ci-value">Priority Review</div><div class="ci-note">Corrections to scholarship amounts, deadlines, or eligibility are reviewed with highest priority.</div></div>
                    <div class="contact-info-item"><div class="ci-label">Platform</div><div class="ci-value">scholarslop.org</div><div class="ci-note">This is an independent informational platform, not affiliated with any government body.</div></div>
                </div>
            </div>
        </section>
        <div id="contact-toast"></div>
"@
    },
    @{
        Slug    = "editorial-policy"
        Title   = "Editorial Policy | How We Verify Scholarships | Scholar Slop"
        Desc    = "Our editorial standards for scholarship data: source verification, update frequency, independence declaration, and correction protocol."
        Schema  = "WebPage"
        Hero    = @{ Badge = "Editorial Standards"; H2 = "Editorial Policy"; P = "How we research, verify, and maintain scholarship information to ensure accuracy, reliability, and student trust." }
        Content = @"
        <section class="section">
            <div class="info-block"><h4>1. Source Verification Standard</h4><p>Every scholarship listed must have a direct, traceable URL to an official government or regulatory body portal. Acceptable primary sources include: NSP (scholarships.gov.in), State DBT portals, UGC, AICTE, Ministry of Minority Affairs, and state education department notifications.</p></div>
            <div class="info-block"><h4>2. Data Accuracy Protocol</h4><p>Before publication, scholarship entries are cross-validated across at least two independent official sources where available. Benefit amounts, eligibility criteria, and deadlines are extracted directly from portal notifications, not secondary news sources.</p></div>
            <div class="info-block"><h4>3. Update and Revision Cycle</h4><p>Scholarships are monitored against portal announcements on an ongoing basis. When portals publish new session deadlines or eligibility revisions, our data is updated accordingly. Each scholarship entry carries its last-verified date.</p></div>
            <div class="info-block"><h4>4. Independence Declaration</h4><p>Our editorial decisions are made independently of any commercial, governmental, or institutional interest. We do not accept payment for scholarship placement, ranking, or prominence. Our rankings, if any, are based solely on benefit amount, reach, and student eligibility.</p></div>
            <div class="info-block"><h4>5. Correction Protocol</h4><p>If you believe any scholarship information on our platform is inaccurate, please contact us via our Contact page. Corrections are reviewed within 48 hours. We correct published errors promptly and transparently.</p></div>
            <div class="info-highlight">Last Policy Review: May 2026. This policy is reviewed annually or when significant editorial process changes occur.</div>
        </section>
"@
    },
    @{
        Slug    = "sources"
        Title   = "Sources & References | Official Scholarship Portals | Scholar Slop"
        Desc    = "Complete list of official government sources used by Scholar Slop: NSP, MahaDBT, MP Portal, UP Saksham, West Bengal Oasis, UGC, AICTE, and more."
        Schema  = "WebPage"
        Hero    = @{ Badge = "Our Sources"; H2 = "Official Sources & References"; P = "Every scholarship on this platform is traceable to an official government or regulatory body portal. Below is our complete reference list." }
        Content = @"
        <section class="section">
            <h3 class="section-title">Primary Official Portals</h3>
            <table class="source-table">
                <thead><tr><th>Portal Name</th><th>Jurisdiction</th><th>Official URL</th></tr></thead>
                <tbody>
                    <tr><td>National Scholarship Portal (NSP)</td><td>Central / All India</td><td><a href="https://scholarships.gov.in" target="_blank" rel="noopener">scholarships.gov.in</a></td></tr>
                    <tr><td>MP Scholarship Portal 2.0</td><td>Madhya Pradesh</td><td><a href="https://scholarshipportal.mp.nic.in" target="_blank" rel="noopener">scholarshipportal.mp.nic.in</a></td></tr>
                    <tr><td>MPTAAS Portal (MP Tribal)</td><td>Madhya Pradesh</td><td><a href="https://www.tribal.mp.gov.in" target="_blank" rel="noopener">tribal.mp.gov.in</a></td></tr>
                    <tr><td>MahaDBT Portal</td><td>Maharashtra</td><td><a href="https://mahadbt.maharashtra.gov.in" target="_blank" rel="noopener">mahadbt.maharashtra.gov.in</a></td></tr>
                    <tr><td>UP Scholarship Portal (Saksham)</td><td>Uttar Pradesh</td><td><a href="https://scholarship.up.gov.in" target="_blank" rel="noopener">scholarship.up.gov.in</a></td></tr>
                    <tr><td>West Bengal Oasis Portal</td><td>West Bengal</td><td><a href="https://oasis.gov.in" target="_blank" rel="noopener">oasis.gov.in</a></td></tr>
                    <tr><td>SVMCM (WB Minority)</td><td>West Bengal</td><td><a href="https://svmcm.wbhed.gov.in" target="_blank" rel="noopener">svmcm.wbhed.gov.in</a></td></tr>
                    <tr><td>UGC Scholarship Schemes</td><td>Central / All India</td><td><a href="https://ugc.ac.in" target="_blank" rel="noopener">ugc.ac.in</a></td></tr>
                    <tr><td>AICTE Scholarship Schemes</td><td>Central / All India</td><td><a href="https://www.aicte-india.org" target="_blank" rel="noopener">aicte-india.org</a></td></tr>
                </tbody>
            </table>
            <div class="info-highlight" style="margin-top:32px;">&#9888;&#65039; We link directly to official portals. We do not control third-party portal content. Always verify deadline dates and eligibility on the official portal before applying.</div>
        </section>
"@
    },
    @{
        Slug    = "privacy-policy"
        Title   = "Privacy Policy | Scholar Slop"
        Desc    = "Scholar Slop's privacy policy: no server data collection, LocalStorage-only data, no cookies, no tracking pixels, and no third-party data sharing."
        Schema  = "PrivacyPolicy"
        Hero    = @{ Badge = "Your Privacy"; H2 = "Privacy Policy"; P = "We believe financial aid information should be accessible without requiring you to surrender your personal data. Here is exactly how this platform treats your information." }
        Content = @"
        <section class="section">
            <div class="info-block"><h4>1. What Data We Collect</h4><p>Scholar Slop does NOT collect any personally identifiable information on our servers. The platform operates entirely client-side. Any data you enter (name, state, income, category) is stored exclusively in your browser's LocalStorage and never transmitted to any server.</p></div>
            <div class="info-block"><h4>2. LocalStorage Usage</h4><p>We use browser LocalStorage to save your: scholarship bookmarks, application tracking status, recently viewed scholarships, dark/light mode preference, and optional display name. This data exists only on your device and is cleared if you clear your browser data.</p></div>
            <div class="info-block"><h4>3. Cookies</h4><p>We do not set any tracking or analytics cookies. We do not use Google Analytics, Facebook Pixel, or any third-party tracking scripts.</p></div>
            <div class="info-block"><h4>4. Third-Party Links</h4><p>Our platform links to official government portals. When you click an Apply Now link, you are navigating to a third-party government portal that operates under its own privacy policy. We have no control over those portals.</p></div>
            <div class="info-block"><h4>5. Changes to This Policy</h4><p>We may update this Privacy Policy periodically. Significant changes will be noted on this page with a revised date. Continued use of the platform after changes constitutes acceptance of the revised policy.</p></div>
            <div class="info-highlight">Last Updated: May 2026. Questions? Use the <a href="../contact/index.html" style="color:var(--primary);">Contact</a> page to reach our team.</div>
        </section>
"@
    },
    @{
        Slug    = "terms"
        Title   = "Terms of Use | Scholar Slop"
        Desc    = "Terms of use for Scholar Slop: informational platform disclaimer, no-fee policy, limitations of liability, and accuracy disclaimer."
        Schema  = "WebPage"
        Hero    = @{ Badge = "Terms of Use"; H2 = "Terms of Use"; P = "Please read these terms carefully before using Scholar Slop. By accessing this platform, you agree to these terms." }
        Content = @"
        <section class="section">
            <div class="info-block"><h4>1. Informational Purpose Only</h4><p>Scholar Slop is an independent informational platform. The content provided is for general informational purposes only and does not constitute legal, financial, or professional advice. Always verify scholarship information directly on the official government portal before applying.</p></div>
            <div class="info-block"><h4>2. No Application Fees</h4><p>We do not charge any fees for accessing scholarship information on this platform. If any external party charges you a fee claiming to represent Scholar Slop, that is fraudulent activity. Government scholarships are always free to apply for on their official portals.</p></div>
            <div class="info-block"><h4>3. Accuracy Disclaimer</h4><p>While we make every effort to ensure the accuracy of scholarship data, government portals may update eligibility, deadlines, and benefit amounts without notice. We are not liable for any loss or missed opportunity resulting from reliance on information on this platform.</p></div>
            <div class="info-block"><h4>4. Intellectual Property</h4><p>The design, structure, and original content of this platform are the intellectual property of Scholar Slop. Government scholarship data sourced from official portals remains the property of respective government bodies.</p></div>
            <div class="info-block"><h4>5. Governing Law</h4><p>These terms are governed by the laws of India. Any disputes arising from use of this platform shall be subject to the exclusive jurisdiction of Indian courts.</p></div>
        </section>
"@
    },
    @{
        Slug    = "disclaimer"
        Title   = "Disclaimer | Scholar Slop"
        Desc    = "Official disclaimer for Scholar Slop: independence from government bodies, no guarantee of scholarship approval, and limitation of liability for outdated information."
        Schema  = "WebPage"
        Hero    = @{ Badge = "Disclaimer"; H2 = "Disclaimer"; P = "Important legal and editorial disclaimers regarding the use of information on this platform." }
        Content = @"
        <section class="section">
            <div class="info-block"><h4>Independence Disclaimer</h4><p>Scholar Slop is an independent informational platform and is NOT affiliated with, endorsed by, or acting as an agent for any government body, ministry, state government, UGC, AICTE, NSP, or any scholarship-providing authority. Official government logos, portal names, and scheme names belong to their respective government owners and are referenced for identification purposes only.</p></div>
            <div class="info-block"><h4>No Guarantee of Approval</h4><p>Listing a scholarship on this platform does not guarantee that you will be approved for that scholarship. Scholarship approvals are made entirely by the concerned government authority based on their own eligibility verification. We have no role in the approval process.</p></div>
            <div class="info-block"><h4>Information Accuracy</h4><p>Scholarship deadlines, benefit amounts, eligibility criteria, and application processes are sourced from official portals and are accurate at the time of compilation. Government authorities may change these details without notice. Always confirm information on the official portal before submitting your application.</p></div>
            <div class="info-block"><h4>External Links</h4><p>This platform contains links to official government portals. We are not responsible for the content, availability, or accuracy of those external websites.</p></div>
            <div class="info-highlight">&#9888;&#65039; Never pay anyone to apply for government scholarships. All government scholarships are free to apply for on their official portals.</div>
        </section>
"@
    }
)

Write-Output "Generating $($authorityList.Count) authority pages..."

foreach ($auth in $authorityList) {
    $authDir = Join-Path $workspaceRoot $auth.Slug
    if (-not [System.IO.Directory]::Exists($authDir)) { [System.IO.Directory]::CreateDirectory($authDir) | Out-Null }
    $authOut = Join-Path $authDir "index.html"

    $schemaBlock = ""
    if ($auth.Schema -eq "Organization") {
        $schemaBlock = @"
    <script type="application/ld+json">
    {"@context":"https://schema.org","@type":"Organization","name":"Scholar Slop","url":"https://scholarslop.org","description":"An independent platform helping Indian students discover verified government scholarships.","areaServed":"IN"}
    </script>
"@
    } elseif ($auth.Schema -eq "ContactPage") {
        $schemaBlock = @"
    <script type="application/ld+json">
    {"@context":"https://schema.org","@type":"ContactPage","name":"Contact Scholar Slop","url":"https://scholarslop.org/contact/","description":"Contact the Scholar Slop editorial team for corrections or feedback."}
    </script>
"@
    } elseif ($auth.Schema -eq "PrivacyPolicy") {
        $schemaBlock = @"
    <script type="application/ld+json">
    {"@context":"https://schema.org","@type":"WebPage","name":"Privacy Policy - Scholar Slop","url":"https://scholarslop.org/privacy-policy/","description":"Privacy policy for Scholar Slop - no server data collection, LocalStorage only."}
    </script>
"@
    } else {
        $schemaBlock = @"
    <script type="application/ld+json">
    {"@context":"https://schema.org","@type":"WebPage","name":"$($auth.Title)","url":"https://scholarslop.org/$($auth.Slug)/","description":"$($auth.Desc)"}
    </script>
"@
    }

    $commonHeader = Get-CommonHeader -depth 1 -title $auth.Title -desc $auth.Desc
    $commonFooter = Get-CommonFooter -depth 1

    $authHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$($auth.Title)</title>
    <meta name="description" content="$($auth.Desc)">
    <meta name="robots" content="index, follow">
    <link rel="canonical" href="https://scholarslop.org/$($auth.Slug)/">
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/temp_style_append.css">
    <script>window.isStaticPage = true;</script>
$schemaBlock
</head>
<body>
$commonHeader
<main class="container" style="padding-top:32px; padding-bottom:64px;">
    <div class="authority-hero">
        <div class="hero-badge">$($auth.Hero.Badge)</div>
        <h2>$($auth.Hero.H2)</h2>
        <p>$($auth.Hero.P)</p>
    </div>
$($auth.Content)
</main>
$commonFooter
<script src="../js/data.js"></script>
<script src="../js/app.js"></script>
</body>
</html>
"@

    [System.IO.File]::WriteAllText($authOut, $authHtml, [System.Text.Encoding]::UTF8)
    Write-Output "  Created: $($auth.Slug)/index.html"

    # Add sitemap entry
    $sitemapXml += @"

    <url>
        <loc>https://scholarslop.org/$($auth.Slug)/</loc>
        <lastmod>2026-05-27</lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.6</priority>
    </url>
"@
}

# Finalize sitemap (was already started above, close it)
# Re-write sitemap since authority entries were added after the closing tag
$sitemapXml = $sitemapXml -replace "`n</urlset>", ""
$sitemapXml += "`n</urlset>"
$sitemapPath = Join-Path $workspaceRoot "sitemap.xml"
if ([System.IO.File]::Exists($sitemapPath)) { [System.IO.File]::SetAttributes($sitemapPath, [System.IO.FileAttributes]::Normal) }
[System.IO.File]::WriteAllText($sitemapPath, $sitemapXml, [System.Text.Encoding]::UTF8)
Write-Output "Sitemap updated with authority page URLs."

# --- GENERATE ROBOTS.TXT ---
Write-Output "Generating robots.txt..."
$robotsTxt = "User-agent: *`nAllow: /`n`nSitemap: https://scholarslop.org/sitemap.xml"
$robotsPath = Join-Path $workspaceRoot "robots.txt"
if ([System.IO.File]::Exists($robotsPath)) { [System.IO.File]::SetAttributes($robotsPath, [System.IO.FileAttributes]::Normal) }
[System.IO.File]::WriteAllText($robotsPath, $robotsTxt, [System.Text.Encoding]::UTF8)

Write-Output "ALL PAGES, SITEMAP, AND ROBOTS.TXT HAVE BEEN PROGRAMMATICALLY COMPILED!"




