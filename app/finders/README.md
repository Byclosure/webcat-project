# Finders

This type of classes responsible for collectiong items based on different conditions.
To prevent lookup methods in models like this: 

```ruby
class Project
  def issues_for_user_filtered_by(user, filter)
    # A lot of logic not related to project model itself
  end
end

issues = project.issues_for_user_filtered_by(user, params)
```

Better use this: 

```ruby
issues = IssuesFinder.new.execute(project, user, filter)
```

It will help keep models thiner
