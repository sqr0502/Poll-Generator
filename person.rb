class Person
  attr_accessor :name, :party
  #initialize our class
  def initialize(name)
    @name = name
  end

  def change_name(new_name)
    if new_name.length > 0
      @name = new_name
    end
  end
end

class Politician < Person
  def initialize(name)
    @name = name
    @votes = 1
  end

  def set_party(party)
    if party.length > 0
      @party = party
    end
  end

  def pretty
    pretty = "Politician: #{@name}   Party: #{@party}"
  end

  def get_party
    @party
  end

  def reset_votes
    @votes = 1
  end

 #increment votes
  def add_vote(number)
    @votes += number
  end

  def get_votes
    @votes
  end

end


class Voter < Person
  def set_politics(politics)
    if politics.length > 0
      @politics = politics
    end
  end

  def pretty
    pretty = "Voter: #{@name} Politics: #{@politics}"
  end

  def get_politics
    @politics
  end

end
