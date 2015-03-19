Users have different abilities depending on the access level they have in a particular group or project.
If a user is both in a project group and in the project itself, the highest permission level is used.
If a user is a GitLab administrator they receive all permissions.

---

#### Project:


| Action| Guest | Reporter | Developer | Master | Owner|
|-------|-------|----------|-----------|--------|------|
|Create new issue|✓|✓|✓|✓|✓|
|Leave comments|✓|✓|✓|✓|✓|
|Write on project wall|✓|✓|✓|✓|✓|
|Pull project code| |✓|✓|✓|✓|
|Download project| |✓|✓|✓|✓|
|Create code snippets| |✓|✓|✓|✓|
|Create new merge request| ||✓|✓|✓|
|Create new branches| ||✓|✓|✓|
|Push to non-protected branches| ||✓|✓|✓|
|Remove non-protected branches| ||✓|✓|✓|
|Add tags| ||✓|✓|✓|
|Write a wiki| ||✓|✓|✓|
|Manage issue tracker| ||✓|✓|✓|
|Add new team members| |||✓|✓|
|Push to protected branches| |||✓|✓|
|Remove protected branches| |||✓|✓|
|Edit project| |||✓|✓|
|Add Deploy Keys to project| |||✓|✓|
|Confiure Project Hooks| |||✓|✓|
|Switch visibility level| ||||✓|
|Transfer project to another namespace| ||||✓|
|Remove project| ||||✓|

#### Group

|Action|Guest|Reporter|Developer|Master|Owner|
|------|-----|--------|---------|------|-----|
|Browse group|✓|✓|✓|✓|✓|
|Edit group|||||✓|
|create project in group|||||✓|
|Manage group members|||||✓|
|Remove group|||||✓|

Any user can remove himself from a group, unless he is the last Owner of the group.
