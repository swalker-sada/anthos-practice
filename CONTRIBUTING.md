Thank you for your interest in contributing to this project.

## Issues, milestones and stories
All your hard work is tracked using *issues*.

In addition to issues, *milestones* are used to track collection of related *issues* towards a particular goal. As an example, all **Use Cases** are managed as *milestones*. Please review current *milestones* for examples.

The *milestones* that track specific **Use Cases** may contain specific user journeys. In this project, the user journeys are referred to as **stories** and are signified by labels. You can use the label ~story to the user journey issues.

## Tracking new ideas
If you have interesting ideas or hear something from a customer. This could be anything, for example improvements to the platform, a new use case or a story, or simply just polishes that could enhance the user experience. 

Create an issue and label it with the ~idea label.
This will get triaged by one of the maintainers.

## Tracking build errors and troubleshooting
Initial build pipelines take about 30 -35 minutes to complete. Once in a while, one or more pipelines may fail. Pipelines for various stages (dev, stage and prod) run in parallel and independent of one another so failure of one pipeline does not cause the entire build process to fail.

If you encounter a failure, check existing issues with the label ~build_errors. If the issue already exists, you can add any additional notes there.
If the issue does not exist, create a new issue with as much detail as possible and label is with the ~build_errors label.

This is useful for the troubleshooting section.

## Labels

The use of labels in issues is encouraged but not required. The following useful labels are already created and can be used in issues. Using labels helps with filtering, tracking and reporting.

| **Label** | **Guidelines** |
| ----------| --------------- |
| `P::0/1/2` | Priority (scoped label) |
| `status::todo/doing` | will work or working on it (like Kanban or Dev Board) |
| `build`	| something that hasn’t been built yet |
| `fix`		| something built that needs fixing |
| `polish`	| something working that could be better |
| `build_errors` | for tracking errors during initial builds |
| `docs`		| documentation |
| `customer`	| customer reference |
| `idea`.       | To track new and awesome ideas |
| `canceled`	|	was planned at one point but will not happen |
| `platform`, `use_case`, `story`	| self explanatory |
