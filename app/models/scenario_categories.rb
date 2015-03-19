class ScenarioCategories
  #Tags
  BUGAUTOMATION = '@bugautomation'
  BUGSOFTWARE = '@bugsoftware'
  BUGFEATURE = '@bugfeature'

  MISSINGAUTOMATION = '@noautomation'
  MISSINGSOFTWARE = '@nosoftware'

  RUNNING = '@running'

  WIP = '@wip'
  SKIPPED = '@skipit'

  #Type
  AUTOMATION = 1
  SOFTWARE = 2
  FEATURE = 3
  ANALYSIS = 4
  NOTYPE = 5

  FAILEDBUG = 6
  WIPANALYSIS = 10
  PENDINGBUG = 11
  REGRESSIONBUG = 12

  #SubType
  BUG = 7
  MISSING = 8
  NOSUBTYPE = 9

  def self.subTypeToString(subtype)
    r = {
      BUG => 'bug',
      MISSING => 'miss',
      NOSUBTYPE => 'nothing'
    }[subtype]

    r.nil? ? '' : r
  end

  def self.typeToString(type)
    r = {
        AUTOMATION => 'automation',
        SOFTWARE => 'software',
        FEATURE => 'feature',
        ANALYSIS => 'analysis',
        FAILEDBUG => 'bug',
        REGRESSIONBUG => 'regression bug',
        PENDINGBUG => 'missing automation',
        WIPANALYSIS => 'wip analysis',
        NOTYPE => 'nothing'
    }[type]

    r.nil? ? '' : r
  end

  def self.categorize(tags, result)
    types = []

    if(tags.include? BUGAUTOMATION)
      types << {
        :type => AUTOMATION,
        :subtype => BUG,
        :description => 'tagged with bug in automation'
      }
    end

    if(tags.include? BUGSOFTWARE)
      types << {
        :type => SOFTWARE,
        :subtype => BUG,
        :description => 'tagged with bug in software'
      }
    end

    if(tags.include? BUGFEATURE)
      types << {
        :type => FEATURE,
        :subtype => BUG,
        :description => 'tagged with bug in feature'
      }
    end

    if(tags.include? MISSINGAUTOMATION)
      types << {
        :type => AUTOMATION,
        :subtype => MISSING,
        :description => 'tagged with missing automation'
      }
    end

    if(tags.include? MISSINGSOFTWARE)
      types << {
        :type => SOFTWARE,
        :subtype => MISSING,
        :description => 'tagged with missing software'
      }
    end

    has_anal_bug = false
    if(types.length > 0 && result)
      types << {
        :type => ANALYSIS,
        :subtype => BUG,
        :description => 'tagged with problems but passed'
      }
      has_anal_bug = true
    end

    if(tags.include? RUNNING)
      if(!types.empty? && !has_anal_bug)
        types << {
          :type => ANALYSIS,
          :subtype => BUG,
          :description => 'tagged as \'running\' and with problems at the same time'
        }
      elsif(result)
        types << {
          :type => NOTYPE,
          :subtype => NOSUBTYPE,
          :description => 'no problem'
        }
      else
        types << {
          :type => ANALYSIS,
          :subtype => BUG,
          :description => 'tagged as \'running\' but failed'
        }
      end
    elsif(types.length == 0)
      types << {
        :type => ANALYSIS,
        :subtype => MISSING,
        :description => 'no tags. missing analysis'
      }
    end

    {:types => types, :wip => (tags.include? WIP)}
  end
end