Overview
The Nistat function is an interactive tool written in R designed to help users select the appropriate statistical test for their data. The function guides users through a series of questions based on their research objectives, data type, and sample characteristics, ultimately suggesting the most suitable parametric or non-parametric test.

This function is useful for researchers, students, and analysts who are unsure which statistical test to apply to their data. The tool covers a wide range of statistical tests and handles different types of data (nominal, ordinal, interval, continuous).

Features
Supports Parametric and Non-parametric Tests: Determines the appropriate test based on the distribution of the data.
Guides Selection Based on Research Objectives:
Relationship analysis
Difference testing
Prediction modeling
Distribution testing
Includes Goodness-of-fit and Homogeneity Tests for advanced statistical analysis.
Prerequisites
Ensure you have R installed on your system. This function does not require any additional R packages.

Usage Instructions
Copy the Nistat function code into your R environment or save it in a file (e.g., Nistat.R).
Run the function by executing Nistat() in the R console.
Follow the prompts in the console to answer questions about your data and research goals.
The function will guide you through a sequence of questions and display the recommended statistical test based on your responses.
Step-by-Step Example
Here's a quick walkthrough of how to use the function interactively.

Run the function:

R
Copy code
Nistat()
Answer the questions:

The function will ask you about the type of question you’re investigating (relationship, difference, prediction, or distribution).
Based on your answers, it will then prompt you for information on your data type, number of groups, whether the data meets parametric assumptions, etc.
Receive recommendations:

After going through the questions, Nistat will display the most appropriate statistical test for your data and research objective.
Example Usage
Suppose you have two independent groups with interval data and you want to test for a difference between them:

You would start the Nistat() function and select Difference as your research question.
When prompted, specify that you have interval data and two groups.
Indicate that the samples are independent and that your data meets parametric assumptions.
The function will suggest using an Independent Samples t-test.
Supported Statistical Tests
Here is a non-exhaustive list of statistical tests supported by Nistat:

Parametric Tests:

Pearson’s Correlation
Independent Samples t-test
Paired Samples t-test
ANOVA (One-way, Two-way, Repeated Measures)
Simple and Multiple Linear Regression
Non-Parametric Tests:

Spearman’s Rank Correlation
Mann-Whitney U Test
Wilcoxon Signed-Rank Test
Kruskal-Wallis Test
Friedman Test
Goodness-of-Fit and Homogeneity Tests:

Chi-Squared Test for Independence
Fisher’s Exact Test
Kolmogorov-Smirnov Test
Shapiro-Wilk Test for Normality
Levene's and Bartlett's Tests for Homogeneity
Troubleshooting
If the function does not run, ensure that all code for the Nistat function is copied correctly into your R environment.
For help understanding specific tests, consult R’s documentation or statistical resources for additional details.
License
This function is provided as-is under the MIT License. You are free to use, modify, and distribute the code.
