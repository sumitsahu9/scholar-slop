/**
 * Scholar Slop - Data Layer
 * Handles mock data and business logic for status/verification.
 */

// MOCK DATE HELPER (For demo purposes, assumes "today" is fixed or current)
// In a real app, strict server time would be used.
const getToday = () => new Date();

const SCHOLARSHIPS = [
    {
        id: "s1",
        Scholarship_Name: "Pre-Matric Scholarship for SC Students",
        State: "Maharashtra",
        Category: "SC",
        Courses: ["Class 10"],
        Institute_Type: "Government",
        Type: "State",
        Benefit_Amount: "₹25,000 per year",
        Max_Income: 250000,
        Benefit_Type: "Financial assistance for tuition and exam fees",
        Start_Date: "2026-01-01",
        Deadline: "2026-03-31",
        Last_Verified: "2026-02-01",
        Source_Link: "https://mahadbt.maharashtra.gov.in/",
        Overview: "Government of Maharashtra provides financial support to SC students studying in 9th and 10th standard to reduce dropout rates.",
        Eligibility: [
            "Student must belong to Scheduled Caste (SC).",
            "Parent's annual income should be less than ₹2.5 Lakhs.",
            "Student must be a resident of Maharashtra."
        ],
        Documents_Required: [
            "Caste Certificate",
            "Income Certificate",
            "Mark sheet of previous year",
            "Aadhar Card"
        ]
    },
    {
        id: "s2",
        Scholarship_Name: "National Means-cum-Merit Scholarship Scheme (NMMSS)",
        State: "Central",
        Category: "General / SC / ST / OBC",
        Courses: ["Class 9"],
        Institute_Type: "Government",
        Type: "Central",
        Benefit_Amount: "₹12,000 per annum",
        Max_Income: 350000,
        Benefit_Type: "Selected students receive ₹12,000 per annum (₹1,000 per month) for four years, covering Class IX to XII.",
        Start_Date: "June 2, 2025",
        Deadline: "September 30,2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Central Sector Scheme for students to arrest drop-out rates at Class 8 and encourage them to continue study at secondary stage.",
        Eligibility: [
            "Students must be studying in Class 9 at Government, Government-aided, or Local Body schools.",
            "Scored at least 55% marks or equivalent grade in Class 8 examination (5% relaxation for SC/ST).",
            "Parental income not exceeding ₹3.5 Lakhs per annum.",
            "Must pass the selection test (MAT & SAT) with at least 40% in each paper (35% for SC/ST).",
            "Ineligible: Students of NVS, KVS, Sainik schools, and Private schools."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Class VII Marksheet",
            "Class VIII Marksheet (for selection/award)",
            "Income Certificate of Parents",
            "Caste Certificate (if applicable)",
            "Disability Certificate (if applicable)",
            "Domicile Certificate",
            "Bank Passbook or Cancelled Cheque",
            "Recent Passport-size Photograph",
            "School Verification Details / HOI Certificate"
        ]
    },
    {
        id: "s3",
        Scholarship_Name: "Post Matric Scholarship for OBC",
        State: "Uttar Pradesh",
        Category: "OBC",
        Courses: ["Class 11", "Class 12", "Diploma", "UG", "PG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Up to ₹50,000",
        Max_Income: 200000,
        Benefit_Type: "Reimbursement of non-refundable fees",
        Start_Date: "2025-10-01",
        Deadline: "2026-01-31",
        Last_Verified: "2025-12-15",
        Source_Link: "https://scholarship.up.gov.in/",
        Overview: "For OBC students pursuing post-matriculation courses in recognized institutions.",
        Eligibility: [
            "Domicile of Uttar Pradesh.",
            "OBC Category.",
            "Annual family income up to ₹2 Lakhs."
        ],
        Documents_Required: [
            "Caste Certificate",
            "Income Certificate",
            "Fee Receipt"
        ]
    },
    {
        id: "s4",
        Scholarship_Name: "Swami Vivekananda Merit-cum-Means",
        State: "West Bengal",
        Category: "General",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹2,000 - ₹8,000 per month",
        Max_Income: 250000,
        Benefit_Type: "Monthly financial assistance",
        Start_Date: "2026-01-01",
        Deadline: "2026-03-15",
        Last_Verified: "2025-08-01",
        Source_Link: "https://svmcm.wbhed.gov.in/",
        Overview: "Merit-based scholarship for meritorious students of West Bengal.",
        Eligibility: [
            "75% marks in Madhyamik/HS.",
            "Family income less than ₹2.5 Lakhs."
        ],
        Documents_Required: [
            "Mark sheets",
            "Income Certificate"
        ]
    },
    {
        id: "s5",
        Scholarship_Name: "Post Matric Scholarship for ST",
        State: "Central",
        Category: "ST",
        Courses: ["Class 11", "Class 12", "Diploma", "UG", "PG"],
        Institute_Type: "Government",
        Type: "Central",
        Benefit_Amount: "Full maintenance allowance",
        Max_Income: 250000,
        Benefit_Type: "Full maintenance allowance",
        Start_Date: "2026-01-10",
        Deadline: "2026-05-20",
        Last_Verified: "2026-01-25",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Central assistance for ST students to pursue higher education.",
        Eligibility: [
            "Belongs to ST category.",
            "Family income < ₹2.5 Lakhs."
        ],
        Documents_Required: [
            "ST Certificate",
            "Income Proof",
            "Admission Proof"
        ]
    },
    {
        id: "s6",
        Scholarship_Name: "Mukhyamantri Medhavi Vidyarthi Yojana (MMVY)",
        State: "Madhya Pradesh",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Full or partial tuition fee assistance",
        Max_Income: 600000,
        Benefit_Type: "MMVY covers full tuition and admission fees for undergraduate courses in government or private institutions. For engineering, it covers up to ₹1.5 lakh or actual fees, whichever is lower. Hostel seat rent and utilities (excluding mess and caution money) are also covered, ensuring financial ease for students.",
        Start_Date: "August ,2025",
        Deadline: "31 January,2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://medhavikalyan.mp.gov.in/MMVY.aspx",
        Overview: "State government scholarship for meritorious students of Madhya Pradesh.",
        Eligibility: [
            "Eligible candidates must be Madhya Pradesh residents.",
            "Scored 70%+ (MP Board) or 85%+ (CBSE/ICSE) in Class 12.",
            "Family income under INR 6 lakh.",
            "Engineering, medical, or law aspirants must qualify through JEE Mains (rank <1,50,000), NEET, or CLAT, respectively, and be enrolled in recognised institutions.",
            "For detailed information, refer to the eligibility section of the article mentioned above."
        ],
        Documents_Required: [
            "Class 10 Marksheet",
            "Class 12 Marksheet",
            "Domicile Certificate of Madhya Pradesh",
            "Income Certificate",
            "Aadhaar Card",
            "Samagra ID",
            "Admission Proof",
            "Fee Receipt",
            "Bank Account Details (Aadhaar-linked)",
            "Passport size photograph",
            "Entrance Exam Scorecard (JEE/NEET/CLAT, if applicable)"
        ]
    },
    {
        id: "s7",
        Scholarship_Name: "Post Matric Scholarship (MPTAAS)",
        State: "Madhya Pradesh",
        Category: "SC / ST / OBC",
        Courses: ["Class 11", "Class 12", "Diploma", "UG", "PG", "Ph.D", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹230 to ₹2,800 monthly stipend + tuition fee reimbursement",
        Max_Income: 250000,
        Benefit_Type: "The MPTAAS scholarship provides a monthly stipend ranging from ₹230 to ₹1,500 for day scholars and ₹380 to ₹2,800 for hostellers, depending on the course. It also covers full tuition fee reimbursement, hostel fees, and allowances for books and travel.",
        Start_Date: "August 16,2025",
        Deadline: "January 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://www.tribal.mp.gov.in/MPTAAS",
        Overview: "Financial assistance for SC/ST/OBC students of Madhya Pradesh studying at post-matriculation level to promote access to higher education.",
        Eligibility: [
            "Must be a permanent resident of Madhya Pradesh.",
            "Must belong to Scheduled Caste (SC), Scheduled Tribe (ST), or Other Backward Class (OBC).",
            "Must be enrolled in a recognised post-matric course (Class 11/12, UG, PG, Ph.D, Professional).",
            "Annual family income limit: SC/ST < ₹2.5 Lakhs, OBC < ₹1.5 Lakhs.",
            "Parents must not be employed in any government institution.",
            "Must meet minimum attendance requirements.",
            "Must have valid Aadhaar e-KYC linked to Samagra ID and Bank Account."
        ],
        Documents_Required: [
            "Aadhaar Card (Student and Parents)",
            "Samagra ID (Student and Family)",
            "Domicile Certificate of Madhya Pradesh",
            "Caste Certificate (SC/ST/OBC)",
            "Income Certificate",
            "Previous Class Marksheet",
            "Admission Proof and Fee Receipt",
            "Bank Passbook (Aadhaar-linked)",
            "Recent Passport-size Photograph",
            "Transfer Certificate or Bonafide Certificate"
        ]
    },
    {
        id: "s9",
        Scholarship_Name: "Gaon Ki Beti Yojana 2026",
        State: "Madhya Pradesh",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹5,000 to ₹7,500 per year",
        Max_Income: 1000000,
        Benefit_Type: "Eligible girl students receive financial assistance of ₹500 per month for 10 months, totaling ₹5,000 per year for conventional graduation courses. Those enrolled in technical or medical courses receive ₹750 per month for 10 months, totaling ₹7,500 per year.",
        Start_Date: "May 15, 2026.",
        Deadline: "December 31,2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Financial assistance to rural meritorious girl students of MP to encourage higher education.",
        Eligibility: [
            "Must be a resident of a rural area in Madhya Pradesh (Gaon Ki Beti).",
            "Must have passed Class 12 with 60% or more marks.",
            "Must hold a valid 'Gaon Ki Beti' Certificate.",
            "Applicable to SC / ST / OBC / General / EWS / BPL categories."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Samagra ID",
            "Class 12th Marksheet",
            "Domicile Certificate",
            "Income Certificate of parents",
            "Caste Certificate (if applicable)",
            "Gaon Ki Beti Certificate (Village Daughter Certificate)",
            "Current College Code and Branch Code",
            "Bank Passbook",
            "Recent Passport-size Photograph",
            "Mobile Number and Email ID of the candidate"
        ]
    },
    {
        id: "s10",
        Scholarship_Name: "Mukhya Mantri Jan Kalyan Shiksha Protsahan Yojana",
        State: "Madhya Pradesh",
        Category: "General / SC / ST / OBC / EWS",
        Courses: ["UG", "PG", "Polytechnic", "Diploma", "ITI", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Full Fee Coverage (Tuition & Admission)",
        Max_Income: 1000000,
        Benefit_Type: "Full Fee Coverage: Covers admission and tuition fees for UG, PG, Polytechnic, Diploma, and ITI courses. Private Engineering: Benefits are capped at ₹1.5 lakh or the actual fee (whichever is less). Medical & Law: Provides full tuition fees for students admitted to MBBS/BDS or law (NLU/DU) through competitive exams. Exclusions: Does not cover mess charges or caution money.",
        Start_Date: "N/A",
        Deadline: "29 June 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Financial assistance for children of unorganized workers (Sambal Card holders) to pursue higher education without financial constraints.",
        Eligibility: [
            "Student must be a permanent resident of Madhya Pradesh.",
            "Parents must be registered as unorganized workers in the Labor Department, MP (Sambal Card).",
            "Admission in Diploma/Degree/Certificate courses at Govt Medical/Paramedical colleges.",
            "Admission in UG/PG courses at Govt/Aided Colleges/Universities, Polytechnic, or ITI.",
            "Engineering: JEE Mains rank < 1.5 Lakh. Full fee (Govt) or 1.5 Lakh/Actual (Pvt/Aided/Grant-based).",
            "Medical: Admission via NEET in Centre/State Govt or Private Medical colleges.",
            "Law: Admission via CLAT in National Law University or Delhi University."
        ],
        Documents_Required: [
            "Parent's Unorganized Worker Registration Certificate (Sambal Card)",
            "Aadhaar Card (Linked to mobile number)",
            "Samagra ID (Student and Family)",
            "Domicile Certificate of Madhya Pradesh",
            "Income Certificate",
            "Class 10th and 12th Marksheets",
            "Previous Qualifying Examination Marksheet",
            "Entrance Exam Scorecard (JEE/NEET/CLAT, if applicable)",
            "Admission Receipt and Fee Structure",
            "Bank Passbook (Aadhaar-linked)",
            "Recent Passport-size Photograph",
            "Mobile Number and Email ID"
        ]
    },
    {
        id: "s11",
        Scholarship_Name: "National Overseas Scholarship",
        State: "Central",
        Category: "SC / ST",
        Courses: ["PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "Full funding for studying abroad",
        Max_Income: 600000,
        Benefit_Type: "Covers tuition fees, maintenance allowance, and travel",
        Start_Date: "2026-02-01",
        Deadline: "2026-04-30",
        Last_Verified: "2026-02-01",
        Source_Link: "https://nosmsje.gov.in/",
        Overview: "For students from marginalized communities to pursue master's or PhD programs outside India.",
        Eligibility: [
            "Belongs to SC, Denotified Tribes, or Landless Agricultural Laborer categories.",
            "Family income below ₹6 Lakhs.",
            "Minimum 60% marks in bachelor's degree."
        ],
        Documents_Required: [
            "Caste Certificate",
            "Income Proof",
            "Passport copy",
            "Offer letter from foreign university"
        ]
    },
    {
        id: "s12",
        Scholarship_Name: "Central Sector Scheme of Scholarship (CSSS)",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹12,000 - ₹20,000 per annum",
        Max_Income: 450000,
        Benefit_Type: "Graduation (1st-3rd yr): ₹12,000/yr. Graduation (4th-5th yr Professional/Integrated): ₹20,000/yr. PG: ₹20,000/yr. Technical (B.Tech 1st-3rd yr): ₹12,000/yr.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Financial assistance to meritorious students from low-income families to meet day-to-day expenses while pursuing higher studies.",
        Eligibility: [
            "Indian National.",
            "Passed Class 12 with minimum 80th percentile in relevant stream (Science, Commerce, Humanities).",
            "Must be enrolled in regular UG/PG degree course in recognized Colleges/Universities/AICTE agreed institutions.",
            "Family income not exceeding ₹4.5 Lakhs per annum.",
            "Not eligible: Diploma, Correspondence, or Distance mode students.",
            "Renewal: Min 50% marks in annual exam and 75% attendance. Must apply on NSP."
        ],
        Documents_Required: [
            "Aadhaar Card (or enrollment slip)",
            "Class 12 Marksheet & Passing Certificate",
            "Income Certificate of Parents",
            "Caste Certificate (if applicable)",
            "Disability Certificate (if applicable)",
            "Bonafide Student Certificate from College/University",
            "Bank Passbook (Aadhaar linked)"
        ]
    },
    {
        id: "s13",
        Scholarship_Name: "AICTE Pragati Scholarship for Girls",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "Diploma"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹50,000 per year",
        Max_Income: 800000,
        Benefit_Type: "Lump sum amount towards college fees, purchase of computer, stationeries, books, equipment, software, etc. No other additional grant.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Scheme by AICTE, MoE for Girl Students admitted in 1st/2nd year of technical degree/diploma course in AICTE approved institution to empower women.",
        Eligibility: [
            "The applicant must be a Girl Student.",
            "Must be pursuing 1st year of Degree/Diploma course OR 2nd year of Degree/Diploma course through lateral entry.",
            "Annual family income from all sources must not be more than ₹8,0,000/- during the current financial year.",
            "Maximum two girl children per family are eligible.",
            "All eligible girls from 13 Union Territories and North Eastern States are given scholarship.",
            "Gap period between qualifying exam and admission not more than 2 years."
        ],
        Documents_Required: [
            "Copy of SSC/10th certificate.",
            "Copy of HSC/12th certificate (In case of Degree level).",
            "Copy of ITI certificate (In case of Lateral Entry for Diploma level).",
            "Copy of Diploma certificate (In case of Lateral Entry for Degree level).",
            "Bank Passbook",
            "Category Certificate",
            "Aaddhar Card",
            "Study Certificate (Appendix-I)",
            "Annual Family Income Certificate (Appendix-II)",
            "Parent’s Declaration (Appendix-III)",
            "Bank Mandate Form (Appendix-IV)"
        ]
    },
    {
        id: "s14",
        Scholarship_Name: "NSP Post Matric Scholarship for Minorities 2025",
        State: "Central",
        Category: "General / OBC / SC / ST (Minority Communities: Muslim, Christian, Sikh, Buddhist, Jain, Parsi)",
        Courses: ["Class 11", "Class 12", "Diploma", "UG", "PG", "ITI", "Polytechnic", "Technical", "Professional"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "Up to ₹20,000 Fees + Maintenance Allowance",
        Max_Income: 200000,
        Benefit_Type: "Course Fee Refund: Class 11/12 (₹7k), Tech/Vocational (₹10k), UG/PG (₹3k), Professional (₹20k). Maintenance (10mo): Class 11/12 (Hosteller ₹7k/Day ₹3.5k), Tech/Vocational (Hosteller ₹10k/Day ₹7k), UG/PG (Hosteller ₹6k/Day ₹3k).",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "A key initiative by Ministry of Minority Affairs to empower meritorious students from economically weaker sections of notified minority communities. Covers tuition fees, maintenance, and incidental expenses.",
        Eligibility: [
            "Community: Muslim, Christian, Sikh, Buddhist, Jain, Parsi.",
            "Enrolled in Class 11, 12, UG, PG, Technical, or Professional courses.",
            "Academic: Secured min 50% marks in previous qualifying exam.",
            "Income: Annual family income <= ₹2 Lakhs.",
            "Limit: Max 2 students per family.",
            "Aadhaar: Mandatory (or Enrolment ID).",
            "Not Eligible: Correspondence/Distance learning, Management quota/non-regular admissions, Unrecognized institutions.",
            "Double Benefit: Cannot avail other scholarship schemes."
        ],
        Documents_Required: [
            "Aadhaar Card or Enrolment ID",
            "Minority Community Certificate (Self-certified >18, Parent-certified <18)",
            "Income Certificate (Tehsildar/Competent Authority)",
            "Marksheet of previous qualifying exam (50% min)",
            "Fee Receipt of current course",
            "Bank Account Details (Passbook copy linked with Aadhaar)",
            "Domicile Certificate",
            "Bonafide Certificate from Institution",
            "Passport-size photograph"
        ]
    },
    {
        id: "s15",
        Scholarship_Name: "Vikramaditya Free Education Scheme (Vikramaditya Yojana)",
        State: "Madhya Pradesh",
        Category: "General",
        Courses: ["UG", "Graduation"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹2,500 per annum",
        Max_Income: 120000,
        Benefit_Type: "Annual financial assistance of a maximum of ₹ 2,500/-.",
        Start_Date: "2026-06-01",
        Deadline: "2026-09-30",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Scholarship by MP Govt Dept of Higher Education for General category students pursuing further education after Class 12.",
        Eligibility: [
            "Must belong to General category.",
            "Must have scored at least 60% marks in Class 12 examination.",
            "Annual family income should not exceed ₹1,20,000 (for higher education) or ₹54,000 (for graduation)."
        ],
        Documents_Required: [
            "Samagra ID",
            "Current college code",
            "Branch code",
            "Recent passport size photograph",
            "Caste certificate",
            "Income certificate of parents",
            "Resident proof"
        ]
    },
    {
        id: "s16",
        Scholarship_Name: "Pratibha Kiran Scholarship",
        State: "Madhya Pradesh",
        Category: "General / OBC / SC / ST",
        Courses: ["UG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Up to ₹5,000 per annum",
        Max_Income: 250000,
        Benefit_Type: "Financial assistance for urban girl students (₹500/month for 10 months).",
        Start_Date: "Always Open",
        Deadline: "Open throughout the academic session",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Scholarship by Dept of Higher Education, MP for urban girl students from BPL families.",
        Eligibility: [
            "Permanent resident of Madhya Pradesh.",
            "Resident of urban area of MP.",
            "Passed Class 12 with 60% or more marks.",
            "Belong to BPL family.",
            "Must be a Girl Student."
        ],
        Documents_Required: [
            "Aadhaar card",
            "Urban residential certificate",
            "Income certificate",
            "BPL certificate",
            "12th class mark sheet",
            "Passport-size photo",
            "Copy of bank passbook",
            "Birth certificate",
            "Caste certificate",
            "Mobile number"
        ]
    },
    {
        id: "s17",
        Scholarship_Name: "MPTAAS OBC Post Matric Scholarship",
        State: "Madhya Pradesh",
        Category: "OBC",
        Courses: ["Class 11", "Class 12", "Diploma", "UG", "PG", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹230 to ₹1,500 monthly stipend + tuition reimbursement",
        Max_Income: 150000,
        Benefit_Type: "Covers monthly allowances and full/partial tuition fee waivers depending on course guidelines.",
        Start_Date: "August 16, 2025",
        Deadline: "January 31, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://www.tribal.mp.gov.in/MPTAAS",
        Overview: "Post-matric financial assistance specifically for OBC students in Madhya Pradesh studying in recognized higher education courses.",
        Eligibility: [
            "Permanent resident of Madhya Pradesh.",
            "Belongs to Other Backward Classes (OBC) category.",
            "Annual family income must not exceed ₹1.5 Lakhs.",
            "Enrolled in a recognized post-matric course."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Samagra ID",
            "OBC Caste Certificate",
            "Income Certificate",
            "Previous Class Marksheet",
            "College Fee Receipt",
            "Bank Passbook copy"
        ]
    },
    {
        id: "s18",
        Scholarship_Name: "Pre-Matric Scholarship for SC Students (MP)",
        State: "Madhya Pradesh",
        Category: "SC",
        Courses: ["Class 10"],
        Institute_Type: "Government",
        Type: "State",
        Benefit_Amount: "₹3,000 to ₹4,000 per year",
        Max_Income: 250000,
        Benefit_Type: "Provides support for school tuition fees, book costs, and academic supplies for high school students.",
        Start_Date: "July 1, 2025",
        Deadline: "December 15, 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "MP State scholarship designed for SC students in Class 9 and 10 to encourage secondary school retention and reduce dropouts.",
        Eligibility: [
            "Permanent resident of Madhya Pradesh.",
            "Must belong to Scheduled Caste (SC) category.",
            "Parental annual income must be below ₹2.5 Lakhs.",
            "Studying in a government or recognized school."
        ],
        Documents_Required: [
            "Student Aadhaar Card",
            "Caste Certificate",
            "Income Certificate of parents",
            "Samagra Family ID",
            "Class 8th / 9th Marksheet"
        ]
    },
    {
        id: "s19",
        Scholarship_Name: "Pre-Matric Scholarship for ST Students (MP)",
        State: "Madhya Pradesh",
        Category: "ST",
        Courses: ["Class 10"],
        Institute_Type: "Government",
        Type: "State",
        Benefit_Amount: "₹3,000 to ₹4,500 per year",
        Max_Income: 250000,
        Benefit_Type: "Covers standard tuition, exam fees, and additional learning materials allowances.",
        Start_Date: "July 1, 2025",
        Deadline: "December 15, 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Pre-matric financial assistance for Scheduled Tribe (ST) students in Class 9 and 10 in Madhya Pradesh.",
        Eligibility: [
            "Permanent resident of Madhya Pradesh.",
            "Must belong to Scheduled Tribe (ST) category.",
            "Annual family income must not exceed ₹2.5 Lakhs.",
            "Regular attendance in a recognized school."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "ST Caste Certificate",
            "Parental Income Proof",
            "Samagra ID",
            "Previous Class Marksheet"
        ]
    },
    {
        id: "s20",
        Scholarship_Name: "Pre-Matric Scholarship for OBC Students (MP)",
        State: "Madhya Pradesh",
        Category: "OBC",
        Courses: ["Class 10"],
        Institute_Type: "Government",
        Type: "State",
        Benefit_Amount: "₹1,500 to ₹2,500 per year",
        Max_Income: 250000,
        Benefit_Type: "Direct scholarship support for secondary academic study.",
        Start_Date: "July 1, 2025",
        Deadline: "December 15, 2026 (Tentative)",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Financial support for Other Backward Classes (OBC) students enrolled in Class 9 and 10 across Madhya Pradesh.",
        Eligibility: [
            "Domicile of Madhya Pradesh.",
            "OBC Social Category.",
            "Family income under ₹2.5 Lakhs.",
            "Regularly attending high school."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "OBC Caste Certificate",
            "Income Proof of Parents",
            "Samagra Family ID",
            "Marksheet of previous grade"
        ]
    },
    {
        id: "s21",
        Scholarship_Name: "Awas Sahayata Yojana for SC/ST Students (MP)",
        State: "Madhya Pradesh",
        Category: "SC / ST",
        Courses: ["UG", "PG", "Diploma", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹1,000 to ₹2,000 per month housing rent support",
        Max_Income: 250000,
        Benefit_Type: "Monthly rental assistance allowance for students residing in rented rooms or private hostels away from home.",
        Start_Date: "August 16, 2025",
        Deadline: "January 31, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://www.tribal.mp.gov.in/MPTAAS",
        Overview: "MP Tribal & SC Department rental housing assistance program for students pursuing college education outside their hometown.",
        Eligibility: [
            "Domicile of Madhya Pradesh.",
            "SC or ST Category student.",
            "Family income below ₹2.5 Lakhs.",
            "Enrolled in regular UG/PG/Diploma courses in a city outside their hometown.",
            "Must be living in rented accommodation (not college hostel)."
        ],
        Documents_Required: [
            "Caste Certificate",
            "Rent Agreement",
            "Landlord's Self-Declaration & Electricity Bill",
            "Income Proof",
            "College Bonafide Certificate",
            "Aadhaar Card & Samagra ID"
        ]
    },
    {
        id: "s22",
        Scholarship_Name: "Minority Post-Matric Scholarship (MP State)",
        State: "Madhya Pradesh",
        Category: "Minority",
        Courses: ["Class 11", "Class 12", "Diploma", "UG", "PG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Up to ₹10,000 per year",
        Max_Income: 200000,
        Benefit_Type: "Partial fee waivers and standard maintenance allowances.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "State-matched financial assistance program for students belonging to notified minority communities in MP.",
        Eligibility: [
            "Permanent resident of Madhya Pradesh.",
            "Belongs to Minority community (Muslim, Christian, Sikh, Buddhist, Jain, Parsi).",
            "Parent's annual income not exceeding ₹2 Lakhs.",
            "Minimum 50% marks in previous year's exams."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Minority Self-Declaration",
            "Domicile Proof",
            "Parents' Income Certificate",
            "College Fee Structure & Admission Receipt"
        ]
    },
    {
        id: "s23",
        Scholarship_Name: "EWS Merit Scholarship (MP State)",
        State: "Madhya Pradesh",
        Category: "General",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹5,000 per annum",
        Max_Income: 600000,
        Benefit_Type: "Merit-based lumpsum financial scholarship for EWS category students.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Financial assistance for meritorious students belonging to Economically Weaker Sections (EWS) in MP.",
        Eligibility: [
            "Resident of MP.",
            "EWS Category (General category with valid EWS Certificate).",
            "Annual family income under ₹6 Lakhs.",
            "Minimum 60% marks in Class 12."
        ],
        Documents_Required: [
            "EWS Certificate",
            "Class 12th Marksheet",
            "Income Proof",
            "Bank Account Copy",
            "Aadhaar Card"
        ]
    },
    {
        id: "s24",
        Scholarship_Name: "Higher Education Merit Scholarship (MP State)",
        State: "Madhya Pradesh",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹5,000 to ₹10,000 per year",
        Max_Income: 500000,
        Benefit_Type: "Financial merit-based assistance awarded annually.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Merit scholarship provided by the Department of Higher Education, MP, for university toppers and rank-holders.",
        Eligibility: [
            "Resident of Madhya Pradesh.",
            "Top rank holder in college/university entrance or previous qualifying exams.",
            "Family income under ₹5 Lakhs."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Previous Class Merit / Rank Rank Proof",
            "Domicile of MP",
            "Income Proof of Parents",
            "Bank Account Details"
        ]
    },
    {
        id: "s25",
        Scholarship_Name: "Technical Education ITI & Polytechnic Scholarship MP",
        State: "Madhya Pradesh",
        Category: "General / OBC / SC / ST",
        Courses: ["Diploma"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Full fee reimbursement + monthly allowances",
        Max_Income: 300000,
        Benefit_Type: "Full tuition reimbursement for ITI/Polytechnic technical diplomas.",
        Start_Date: "July 15, 2025",
        Deadline: "January 31, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "MP Technical Education Department scholarship targeting students pursuing vocational diploma courses.",
        Eligibility: [
            "Domicile of MP.",
            "Enrolled in a recognized Polytechnic, ITI, or technical training institute.",
            "Parental annual income under ₹3 Lakhs."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Samagra ID",
            "Marksheets",
            "Admission Letter & ITI/Polytechnic Fee Receipt",
            "Income & Domicile Certificates"
        ]
    },
    {
        id: "s26",
        Scholarship_Name: "Dr. Shyama Prasad Mukherjee Scholarship for UG/PG (MP)",
        State: "Madhya Pradesh",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹10,000 to ₹20,000 per year",
        Max_Income: 300000,
        Benefit_Type: "Direct scholarship support for regular college tuition fees.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "Financial support for students in MP who scored excellent marks in board exams and belong to low-income groups.",
        Eligibility: [
            "Permanent resident of MP.",
            "Scored 80% or more marks in Class 12 board exams.",
            "Annual family income under ₹3 Lakhs."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Samagra ID",
            "Class 12th Board Marksheet",
            "Income Certificate",
            "College Admission proof"
        ]
    },
    {
        id: "s27",
        Scholarship_Name: "Vikramaditya Free Education Scheme for Law Students (MP)",
        State: "Madhya Pradesh",
        Category: "General",
        Courses: ["UG", "Professional"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "Up to ₹5,000 per year fee waiver",
        Max_Income: 120000,
        Benefit_Type: "Covers tuition fees and admission fees up to actual or ₹5,000, whichever is less.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "A sub-branch scheme under Vikramaditya Yojana providing free college education to meritorious General category students pursuing Law.",
        Eligibility: [
            "Domicile of Madhya Pradesh.",
            "General category candidate.",
            "Scored 60% or more in Class 12 board exams.",
            "Enrolled in regular LL.B. or integrated Law degree.",
            "Family income under ₹1.2 Lakhs."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "General Category Proof",
            "Class 12th Marksheet",
            "Law College Admission Proof & Fee Receipt",
            "Domicile and Income Certificate"
        ]
    },
    {
        id: "s28",
        Scholarship_Name: "Awas Sahayata Yojana for OBC Students (MP)",
        State: "Madhya Pradesh",
        Category: "OBC",
        Courses: ["UG", "PG", "Diploma"],
        Institute_Type: "Both",
        Type: "State",
        Benefit_Amount: "₹500 to ₹1,200 per month housing rent assistance",
        Max_Income: 150000,
        Benefit_Type: "Rental housing reimbursement support for OBC students residing in rented places.",
        Start_Date: "August 16, 2025",
        Deadline: "January 31, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarshipportal.mp.nic.in/",
        Overview: "OBC housing rental assistance for higher education students enrolled outside their residential block in MP.",
        Eligibility: [
            "OBC Category resident of MP.",
            "Annual family income less than ₹1.5 Lakhs.",
            "Enrolled in recognized higher education college outside hometown.",
            "Residing in rented accommodation."
        ],
        Documents_Required: [
            "OBC Certificate",
            "Rent Agreement copy",
            "Electricity Bill & Landlord declaration",
            "Aadhaar Card & Samagra ID",
            "Bonafide certificate"
        ]
    },
    {
        id: "s29",
        Scholarship_Name: "AICTE Saksham Scholarship for Disabled Students",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "Diploma"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹50,000 per year",
        Max_Income: 800000,
        Benefit_Type: "Direct lumpsum allowance towards college fee reimbursement, books, laptop, or software.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Central Sector initiative by AICTE to support specially-abled students pursuing professional technical degrees.",
        Eligibility: [
            "Indian National.",
            "Specially-abled candidate with a disability level of 40% or more.",
            "Enrolled in regular AICTE approved degree/diploma courses.",
            "Family income under ₹8 Lakhs per year."
        ],
        Documents_Required: [
            "Disability Certificate (min 40%)",
            "Aadhaar Card",
            "Current college admission fee receipt",
            "Parental Income Certificate",
            "Previous Year Marksheets"
        ]
    },
    {
        id: "s30",
        Scholarship_Name: "UGC Single Girl Child Scholarship (Savitribai Phule)",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹36,200 per year",
        Max_Income: 10000000,
        Benefit_Type: "Direct annual fellowship transfer to support postgraduate university studies.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "UGC fellowship for girls who are the single child of their parents, pursuing a master's degree.",
        Eligibility: [
            "Girl student who is the only child of her parents.",
            "Enrolled in regular 1st year of Master's degree in a recognized university.",
            "No absolute income ceiling limits apply."
        ],
        Documents_Required: [
            "Affidavit on ₹50 Stamp Paper (Single Girl Child proof)",
            "Aadhaar Card",
            "Postgraduation Admission Letter",
            "Undergraduation Marksheet",
            "Bank Account copy"
        ]
    },
    {
        id: "s31",
        Scholarship_Name: "UGC PG Merit Scholarship for University Rank Holders",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹3,100 per month for 2 years",
        Max_Income: 10000000,
        Benefit_Type: "Monthly support scholarship directly to help cover university post-graduation expenses.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Scholarship to attract meritorious rank-holders of graduation to postgraduate studies in recognized universities.",
        Eligibility: [
            "Scored 1st or 2nd rank in graduation board/university examinations.",
            "Age limit below 30 years at the time of PG admission.",
            "Enrolled in 1st year Master's degree in recognized university."
        ],
        Documents_Required: [
            "University Rank Certificate",
            "Aadhaar Card",
            "UG Passing Certificate & mark sheet",
            "PG admission details",
            "Institution Bonafide Certificate"
        ]
    },
    {
        id: "s32",
        Scholarship_Name: "UGC Ishan Uday Special Scholarship for NER",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["UG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹5,400 to ₹7,800 per month",
        Max_Income: 450000,
        Benefit_Type: "Monthly stipend of ₹5,400 for general degree and ₹7,800 for professional/technical graduation.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Special scholarship scheme by UGC for North Eastern Region (NER) students to promote higher education.",
        Eligibility: [
            "Permanent resident of North Eastern States (Assam, Manipur, Mizoram, Nagaland, Meghalaya, Tripura, Arunachal Pradesh, Sikkim).",
            "Passed Class 12 board exams.",
            "Family income under ₹4.5 Lakhs.",
            "Enrolled in regular UG degree in any Indian university."
        ],
        Documents_Required: [
            "NER Domicile Certificate",
            "Parental Income Proof",
            "Class 12th Marksheet",
            "UG Admission Receipt",
            "Aadhaar Card"
        ]
    },
    {
        id: "s33",
        Scholarship_Name: "INSPIRE Scholarship for Higher Education (SHE)",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹80,000 per year",
        Max_Income: 10000000,
        Benefit_Type: "Covers annual academic scholarship of ₹60,000 + ₹20,000 mentorship grant for research projects.",
        Start_Date: "November 1, 2025",
        Deadline: "December 31, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://online-inspire.gov.in/",
        Overview: "DST central initiative aiming to attract talented youth to study natural and basic sciences at college level.",
        Eligibility: [
            "Indian National.",
            "Top 1% rankers in Class 12 board examinations (State or Central boards).",
            "Enrolled in regular B.Sc., B.S., or Int. M.Sc./M.S. in natural/basic sciences.",
            "Age limit between 17 and 22 years."
        ],
        Documents_Required: [
            "Class 12th Marksheet & Passing Certificate",
            "Class 10th Certificate",
            "Advisory Note / Board Rank Certificate",
            "College Admission Proof",
            "Aadhaar Card",
            "Endorsement Certificate by Principal"
        ]
    },
    {
        id: "s34",
        Scholarship_Name: "PM Scholarship Scheme for CAPF & Assam Rifles",
        State: "Central",
        Category: "General / OBC / SC / ST",
        Courses: ["UG", "PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹30,000 to ₹36,000 per year",
        Max_Income: 10000000,
        Benefit_Type: "Yearly support of ₹30,000 for boys and ₹36,000 for girls to cover professional college tuition.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Ministry of Home Affairs central scholarship supporting professional higher education for children of CAPF, Assam Rifles, and State Police personnel.",
        Eligibility: [
            "Wards of deceased/retired/serving CAPF or Assam Rifles personnel.",
            "Enrolled in professional degree programs (Engineering, Medical, MBA, MCA, LL.B., etc.).",
            "Scored 60% or more marks in previous qualifying board/degree examinations."
        ],
        Documents_Required: [
            "Service Certificate / Discharge Book",
            "Aadhaar Card",
            "Class 12th Marksheet / UG Marksheet",
            "Admission Letter & College Fee structure",
            "Disability / Martyrdom proof (if applicable)"
        ]
    },
    {
        id: "s35",
        Scholarship_Name: "National Fellowship for Scheduled Caste Candidates (NFSC)",
        State: "Central",
        Category: "SC",
        Courses: ["PG"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "₹37,000 to ₹42,000 per month fellowship",
        Max_Income: 10000000,
        Benefit_Type: "Doctoral research support fellowship: Junior Research Fellowship (JRF) ₹37,000/mo. Senior Research Fellowship (SRF) ₹42,000/mo. Plus contingency grants.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "UGC doctoral fellowship scheme for Scheduled Caste (SC) candidates pursuing M.Phil/Ph.D. in Sciences, Humanities, and Social Sciences.",
        Eligibility: [
            "Belongs to Scheduled Caste (SC) category.",
            "Must have qualified UGC-NET or CSIR-NET.",
            "Enrolled in regular M.Phil or Ph.D. degree in a recognized university."
        ],
        Documents_Required: [
            "SC Caste Certificate",
            "UGC-NET/CSIR-NET Score Card / Award Letter",
            "Aadhaar Card",
            "M.Phil/Ph.D. Admission Receipt & Bonafide Letter",
            "Postgraduation Marksheet"
        ]
    },
    {
        id: "s36",
        Scholarship_Name: "NSP Merit-cum-Means Scholarship for Professional Courses",
        State: "Central",
        Category: "Minority",
        Courses: ["UG", "PG", "Professional"],
        Institute_Type: "Both",
        Type: "Central",
        Benefit_Amount: "Up to ₹20,000 per year reimbursement",
        Max_Income: 250000,
        Benefit_Type: "Full or partial reimbursement of course fee (₹20,000 max) + monthly maintenance allowances.",
        Start_Date: "June 2, 2025",
        Deadline: "December 15, 2026",
        Last_Verified: "2026-02-15",
        Source_Link: "https://scholarships.gov.in/",
        Overview: "Ministry of Minority Affairs central scheme supporting professional and technical graduation for minority candidates.",
        Eligibility: [
            "Indian National.",
            "Belongs to Minority community (Muslim, Christian, Sikh, Buddhist, Jain, Parsi).",
            "Enrolled in regular professional UG/PG degree (Engineering, Medical, Law, etc.).",
            "Parental annual income less than ₹2.5 Lakhs.",
            "Scored minimum 50% marks in Class 12 board exam."
        ],
        Documents_Required: [
            "Aadhaar Card",
            "Minority Self-Declaration",
            "Class 12th / UG mark sheet",
            "Parent's Income Proof Certificate",
            "College Fee Structure & Admission Receipt"
        ]
    }
];

const DataService = {
    /**
     * Determines status based on dates.
     */
    calculateStatus: (startDateStr, deadlineStr) => {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (!startDateStr || startDateStr === "N/A" || !deadlineStr || deadlineStr === "N/A") {
            return "Open";
        }

        const cleanStart = startDateStr.replace(/\s*,\s*/g, ' ').replace(/\.$/, '').trim();
        const cleanEnd = deadlineStr.replace(/\s*,\s*/g, ' ').replace(/\.$/, '').trim();

        const start = new Date(cleanStart);
        const end = new Date(cleanEnd);

        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
            return "Open"; // If custom/tentative date, default to Open
        }

        if (today < start) return "Upcoming";
        if (today > end) return "Closed";

        // "Closing Soon" logic: less than 15 days left
        const diffTime = end - today;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        if (diffDays <= 15) return "Closing Soon";

        return "Open";
    },

    /**
     * Checks if scholarship is verified within last 90 days.
     */
    isVerifiedSafe: (lastVerifiedStr) => {
        if (!lastVerifiedStr || lastVerifiedStr === "N/A") return true;
        const today = new Date();
        const cleanVerified = lastVerifiedStr.replace(/\s*,\s*/g, ' ').replace(/\.$/, '').trim();
        const verifiedDate = new Date(cleanVerified);
        if (isNaN(verifiedDate.getTime())) return true;
        const ninetyDaysMs = 90 * 24 * 60 * 60 * 1000;
        return (today - verifiedDate) <= ninetyDaysMs;
    },

    /**
     * Get processed scholarships based on filters.
     */
    getScholarships: (filters = {}) => {
        return SCHOLARSHIPS.map(s => {
            const status = DataService.calculateStatus(s.Start_Date, s.Deadline);
            const isVerified = DataService.isVerifiedSafe(s.Last_Verified);
            return { ...s, calculatedStatus: status, isSafe: isVerified };
        }).filter(s => {
            // REMOVED: if (!s.isSafe) return false; (Show all scholarships as requested)

            // 1. Mandatory Filters: State & Category
            if (filters.state) {
                const userState = filters.state.toLowerCase().trim();
                const scholState = s.State.toLowerCase().trim();
                const isMatch = scholState === userState || scholState === "central";
                if (!isMatch) return false;
            }

            if (filters.category) {
                const userCat = filters.category.toLowerCase().trim();
                const scholCat = s.Category.toLowerCase().trim();
                // STRICT MATCH: Only show if scholarship explicitly lists the user's category.
                // Previously, it showed "General" scholarships to everyone, which is incorrect for specific schemes like Vikramaditya Yojana.
                const isMatch = scholCat.includes(userCat);
                if (!isMatch) return false;
            }

            // 2. Optional Filters: Education, Income, Institute
            if (filters.education && !s.Courses.includes(filters.education)) {
                return false;
            }

            if (filters.institute && filters.institute !== "Both") {
                if (s.Institute_Type !== "Both" && s.Institute_Type !== filters.institute) {
                    return false;
                }
            }

            if (filters.income) {
                const userIncome = Number(filters.income);
                // If user's income is greater than the scholarship's max limit, they are not eligible.
                if (userIncome > s.Max_Income) return false;
            }

            return true;
        });
    },

    getById: (id) => {
        const item = SCHOLARSHIPS.find(s => s.id === id);
        if (!item) return null;

        const status = DataService.calculateStatus(item.Start_Date, item.Deadline);
        return { ...item, calculatedStatus: status };
    },

    // List of all States/UTs for dropdown
    getAllStates: () => [
        "Andaman and Nicobar Islands", "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar",
        "Chandigarh", "Chhattisgarh", "Dadra and Nagar Haveli", "Daman and Diu", "Delhi", "Goa",
        "Gujarat", "Haryana", "Himachal Pradesh", "Jammu and Kashmir", "Jharkhand", "Karnataka",
        "Kerala", "Ladakh", "Lakshadweep", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
        "Mizoram", "Nagaland", "Odisha", "Puducherry", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu",
        "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"
    ]
};

// Expose to window for app.js
window.DataService = DataService;
