class ProjectBrowseFiles < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedProject
  include SharedPaths

  step 'I should see files from repository' do
    page.should have_content "app"
    page.should have_content "history"
    page.should have_content "Gemfile"
  end

  step 'I should see files from repository for "8470d70"' do
    current_path.should == project_tree_path(@project, "8470d70")
    page.should have_content "app"
    page.should have_content "history"
    page.should have_content "Gemfile"
  end

  step 'I click on "Gemfile.lock" file in repo' do
    click_link "Gemfile.lock"
  end

  step 'I should see it content' do
    page.should have_content "DEPENDENCIES"
  end

  step 'I click link "raw"' do
    click_link "raw"
  end

  step 'I should see raw file content' do
    page.source.should == ValidCommit::BLOB_FILE
  end

  step 'I click button "edit"' do
    click_link 'edit'
  end

  step 'I can edit code' do
    page.execute_script('editor.setValue("GitlabFileEditor")')
    page.evaluate_script('editor.getValue()').should == "GitlabFileEditor"
  end

  step 'I click on "new file" link in repo' do
    click_link 'new-file-link'
  end

  step 'I can see new file page' do
    page.should have_content "New file"
    page.should have_content "File name"
    page.should have_content "Commit message"
  end
end
