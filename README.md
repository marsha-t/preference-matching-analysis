# Officer Posting Matching via Stable Matching Algorithm

This project applies the **Gale-Shapley stable matching algorithm** to support more efficient and consistent decision-making in internal job postings. Originally developed as a proof of concept for an annual HR exercise, it demonstrates how ranked-choice data can be used to automate match assignments fairly and transparently.

## 🧭 Background and Context

In the original process, individuals and directors participating in the exercise were asked to submit a ranked list of their top 3 preferences, given a set of possible postings. These choice sets could differ across individuals and directors, meaning not everyone was selecting from the same pool HR would then manually match individuals to roles, trying to respect these preferences while ensuring fairness across the group.

Although the number of participants was relatively small (~20), the manual process was complex and time-consuming, especially when attempting to honor everyone's preferences and avoid conflicts. HR approached our team to explore whether this could be improved through data-driven and algorithmic approaches.

This project demonstrates that such a process can be **automated and optimized using stable matching techniques**, enabling more **systematic**, **transparent**, and **scalable** outcomes — even in small-scale but high-stakes settings.

> ⚠️ Due to confidentiality constraints, actual data is not shared. Simulated data will be uploaded in future updates to illustrate the workflow end-to-end.

## 💡 Solution Overview

Using the **Gale-Shapley stable matching algorithm**, this solution generates stable matches where no two individuals would prefer each other over their assigned match — ensuring fairness and satisfaction.

The initial implementation in **R** served as a prototype to demonstrate feasibility and usefulness:

- 🧾 Reads and processes preference rankings from Excel
- 🔢 Converts preferences into numerical weights
- ⚙️ Runs the Gale-Shapley algorithm via the `matchingR` package
- 📊 Compares predicted matches to actual outcomes
- 🧩 Evaluates how well each match aligns with participant preferences (1st/2nd/3rd choice)
- 🧮 Assesses whether matches fall within the individual's or director’s original preference set

As the HR team was non-technical, we also designed **Excel-based versions** of the tool that could provide guidance interactively. This included the ability to recompute ideal matches on the fly as some postings were confirmed.

## 🧠 Key Skills Demonstrated

- Optimization and Stable matching theory
- Algorithm implementation with `matchingR`
- Cross-functional communication and tool design (Excel-based decision support)
- Evaluation and visualization of algorithmic predictions vs human decisions

## 🔜 What's Next

- A full **Python implementation** using the `matching` package is in progress.
- I will also provide an **Excel-based template** to demonstrate how this logic can be used without code in small-scale settings.
- A **simulated dataset** and walkthrough will be added to illustrate usage in R, Excel and Python.

## 📈 Broader Applications

While this project was built for internal posting decisions, the same framework can be generalized to a wide range of ranked matching problems:

- 🎓 Mentorship or student-project pairings
- 🏥 Residency or internship placement
- 🧪 Team or project allocations
- 🗳️ Any two-sided matching scenario with preferences

📬 **Let's Connect**  

Feel free to explore the code and contact me if you're working on similar challenges or matching systems!
