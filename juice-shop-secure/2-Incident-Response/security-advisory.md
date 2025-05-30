# Security Advisory

**JSB-2025-001 - JuiceShop Customer Data Security Incident - May 2025**

**Severity Level: MEDIUM**

**Description**

JuiceShop is aware of a security incident that occurred in our preproduction environment on May 21, 2025. Default administrator credentials allowed unauthorized access to our customer data export functionality.

No production systems or real customer data were compromised. This advisory serves to inform our customers about the incident and our response measures.

**What Happened**

During routine security monitoring, we detected unauthorized access to our preproduction environment through default administrator credentials that had not been properly changed during deployment. The incident lasted approximately 45 minutes before being contained.

**Data Involved**

The unauthorized access involved test customer records (2,847 fictional entries) that replicated our production data structure, including:
- Email addresses (test data)
- Customer names (fictional)
- Purchase histories (test transactions)
- Account information (non-production)

**Immediate Actions Taken**

- Isolated affected systems within 45 minutes of detection
- Invalidated all administrative sessions
- Removed default credentials and implemented secure authentication
- Updated JuiceShop platform to version 15.2.1
- Conducted full security audit of all systems

**Customer Impact**

**No real customer data was accessed or compromised.** All affected data was fictional test data used in our preproduction environment. No customer accounts, payment information, or personal data was involved.

**Preventive Measures Implemented**

- Enhanced monitoring and alerting systems
- Mandatory security hardening checklist for all deployments
- Regular security audits of both production and preproduction environments
- Updated incident response procedures

**What We're Doing Going Forward**

- Implementing automated security scanning for all new deployments
- Enhanced monitoring of administrative access across all environments
- Regular third-party security assessments
- Continued investment in cybersecurity infrastructure

**Contact Information**

If you have any questions or concerns about this incident, please contact our customer support team at support@juiceshop.com or call our customer service line.

We take the security of your data seriously and are committed to maintaining the highest standards of protection.

**JuiceShop Security Team**  
Last updated: May 30, 2025
