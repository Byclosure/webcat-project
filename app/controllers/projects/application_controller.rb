class Projects::ApplicationController < ApplicationController
  before_filter :project
  before_filter :repository
  layout :determine_layout

  def authenticate_user!
    # Restrict access to Projects area only
    # for non-signed users
    if !current_user
      id = params[:project_id] || params[:id]
      @project = Project.find_with_namespace(id)

      return if @project && @project.public?
    end

    super
  end

  def determine_layout
    if current_user
      'projects'
    else
      'public_projects'
    end
  end

  def require_branch_head
    unless @repository.branch_names.include?(@ref)
      redirect_to project_tree_path(@project, @ref), notice: "This action is not allowed unless you are on top of a branch"
    end
  end

  def paginate(page_num, expanded, blocks)

    if(page_num.nil?)
      page_num = 1
    else
      page_num = page_num.to_d
    end

    sorted_blocks_unsliced =blocks.sort_by { |i| yield(i).feature }

    if(!(expanded.nil? || expanded.empty?))
      expanded_id = expanded.first

      index = sorted_blocks_unsliced.index { |i| i.id.to_s == expanded_id }

      if(!index.nil?)
        block_page_num = index.fdiv(PER_PAGE).truncate + 1

        if(block_page_num != page_num)
          return {:redirect => true, :addons => {:page => block_page_num}}
        end
      end
    end

    total_results = blocks.length

    offset = (page_num-1)*PER_PAGE
    limit = [ offset+PER_PAGE, total_results+1 ].min
    num_pages = total_results.fdiv(PER_PAGE).ceil
    num_pages = num_pages == 0 ? 1 : num_pages

    blocks_by_feature = {}

    sorted_blocks = sorted_blocks_unsliced[offset..limit-1]

    sorted_blocks.each { |i|
      feature = yield(i).feature

      if(blocks_by_feature[feature].nil?)
        blocks_by_feature[feature] = [i]
      else
        blocks_by_feature[feature] << i
      end
    }

    {:redirect => false, :num_pages => num_pages, :page_num => page_num, :blocks_by_feature => blocks_by_feature}
  end
end
