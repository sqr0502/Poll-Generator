#dependencies
require 'net/http'
require 'rubygems'
require 'json'

require_relative 'person'

#const for prompts and output
MENU_CONST = "What would you like to do? \n(C)reate, (L)ist, (U)pdate, or (V)ote"
CREATE_CONST = "What would you like to create? \n(P)olitician or (V)oter"
NAME_CONST = "First and Last Name: "
PARTY_CONST = "Party? \n(D)emocrat or (R)epublican"
POLITICS_CONST = "Politics? \n (L)iberal, (C)onservative, (T)ea Party, (S)ocialist, or (N)eutral"
UPDATE_TYPE_CONST = "Which would you like to update (v)oter, (p)olitician"
UPDATE_CONST = "Who would you like to update? Choose a number from the list provided above"
NO_LIST_CONST = "Please add a voter or politician."
UPDATE_HEADING_CONST = "Please select from the following list: "
INVALID_ENTRY_CONST = "** %s is not a valid entry ** \n \n "
UPDATE_OPTIONS_CONST = "Update: \n(N)ame or \n(P)arty/(P)olitics"
NAME_UPDATE_CONST = "New name (press enter if no change):"
POLITICS_UPDATE_CONST = "New Politics (press enter if no change):"
PARTY_UPDATE_CONST = "New Party (press enter if no change):"
POLITICIAN_HEADING_CONST = "************ List of Politicians ************"
VOTER_HEADING_CONST = "************ List of Voters ************"
CREATE_CONF_CONST = "*************\nRecord Added - %s \n*************\n"
POLL_HEADING = "%s Party Results\n"
POLL_RESULTS = "Candidate:%s  Total Votes:%s\n"

#instance variables
@politicians = []
@voters = []
@politics = ["Tea Party", "Conservative", "Neutral", "Liberal", "Socialist"]
@parties = ["Democrat", "Republican"]

#reusable method to prompt and get back input
def prompt(string)
  puts string
  user_input = gets.chomp.downcase
  user_input
end

#get party full string based on input
def get_party(party)
  if party == "d"
    party = "Democrat"
  elsif party == "r"
    party = "Republican"
  end
  party
end

#get politics full string based on input
def get_politics(politics)
  case politics
    when "t"
      politics = "Tea Party"
    when "c"
      politics = "Conservative"
    when "n"
      politics = "Neutral"
    when "l"
      politics = "Liberal"
    when "s"
      politics = "Socialist"
  end
  politics
end

#create politician or voter
def create(person)
  #politician or voter object - nil otherwise
  a = nil
  if person == 'p' || person ==  'v'
    name = prompt(NAME_CONST)
    #get politician party
    if person == "p" && name
      #ask for political party
      party = prompt(PARTY_CONST)
      party = get_party(party)
      #create politician
      a = Politician.new(name)
      #set politician party
      a.set_party(party)
      #add to politician list
      @politicians << a
    #get voter party
    elsif person == "v" && name
      #ask for affiliation
      politics = prompt(POLITICS_CONST)
      politics = get_politics(politics)
      puts politics
      #create voter
      a = Voter.new(name)
      #set voter politics
      a.set_politics(politics)
      #add voter to list
      @voters << a
    end
  else #not p or v  - invalid
    printf(INVALID_ENTRY_CONST, person)
  end

  #only if a gets filled with data do we print
  if a
    #print formatted string with name
    printf(CREATE_CONF_CONST, a.pretty())
  end
  a
end

#print list of voters and politicians
def display_list
  #check for politicians
  if @politicians.length > 0
    puts POLITICIAN_HEADING_CONST
    #loop through politicians
    @politicians.each_with_index do |politician, index|
      puts "(" + (index + 1).to_s + ") " + politician.pretty
    end
  end
    #loop through voter
  if @voters.length > 0
    puts VOTER_HEADING_CONST
    @voters.each_with_index do |voters, index|
      puts "(" + (index + 1).to_s + ") " + voters.pretty
    end
  end
end

#find person we need to update
def find(index, type)
  person = nil
  index = index.to_i

  if type == "p"
    person = @politicians[index - 1]
  elsif type == "v"
    person = @voters[index - 1]
  end

  person
end

#method to get one and only one candidate from a party
def get_candidate(party)
   candidate = nil
   @politicians.each do |politician|
    if politician.get_party == party
      candidate = politician
    end
   end
   candidate
end

#method to generate our poll based on project specifications
#returns hash
def generate_poll

    #hash for counters
    politics = {}
    parties = {}

    #build hash
    @politics.each do |politic|
      politics[politic] = 0
    end

    #build hash for parties
    @parties.each do |party|
      #only if the key does not exist add it
      if !parties.has_key?(party)
        candidate = get_candidate(party)
        if candidate
          parties[party] = {candidate:candidate}
        end
      end
    end


    #group votes by voter politics
    @voters.each do |voter|
      politics[voter.get_politics()] += 1
    end

    #build votes based on counts
    politics.each do |key, value|
      rep_vote = 0
      dem_vote = 0
      case key
         when "Tea Party"
           #split 90 / 10
            rep_vote = value * 0.9
            dem_vote = value * 0.1
         when "Conservative"
           #split 75 / 25
            rep_vote = value * 0.75
            dem_vote = value * 0.25
         when "Neutral"
            rep_vote = value * 0.5
            dem_vote = value * 0.5
         when "Liberal"
            rep_vote = value * 0.25
            dem_vote = value * 0.75
         when "Socialist"
            rep_vote = value * 0.1
            dem_vote = value * 0.9
      end
      #check if candidate exists
      if parties["Republican"]
        parties["Republican"][:candidate].add_vote(rep_vote)
      end
      if parties["Democrat"]
        parties["Democrat"][:candidate].add_vote(dem_vote)
      end

    end
  #return parties is hash with candidates of datatype politician
  parties
end


#method to output poll
def print_poll(poll)
    poll.each do |party, value|
      printf("***************************************\n")
      printf(POLL_HEADING, party)

      printf(POLL_RESULTS, value[:candidate].name,value[:candidate].get_votes.to_s )
      printf("***************************************\n")
    end
end

def update(person)
  # user_input = prompt(UPDATE_OPTIONS_CONST)
  #get new name
  new_name = prompt(NAME_UPDATE_CONST)
  #modify name if and only if a name was entered
  person.change_name(new_name)

  #check for person type and update party / politics
  if person.class == "Politician" #politician party
    party = prompt(PARTY_UPDATE_CONST)
    #determine Party
    party = get_party(party)
    #update politician party
    person.set_party(party)
  elsif person.class == "Voter" #voter politics
    politics = prompt(POLITICS_UPDATE_CONST)
    #determine Politics
    politics = get_politics(politics)
    #update politics
    person.set_politics(politics)
  end
end

#main menu - top level prompt
def main_menu
  #begin - get what user wants to do
  user_choice = prompt(MENU_CONST)
  #call our sub_menu
  sub_menu(user_choice)
end

#options crud create read update - no delete for now
def sub_menu(user_choice)
  #check what user wants to do
  case user_choice.downcase
    when "c"
      user_choice = prompt(CREATE_CONST)
      person = create(user_choice)
    when "l"
      display_list
    when "u"
      #check if any politicians or voters
      if @politicians.length > 0 || @voters.length > 0
        display_list
        type = prompt(UPDATE_TYPE_CONST)
        user_choice = prompt(UPDATE_CONST)
        #update politician or voter depending on user input
        person = find(user_choice, type)
        #proceed if person found
        if person
          update(person)
        end
      else
        puts NO_LIST_CONST
      end
    when "v"
      poll = generate_poll
      print_poll(poll)
  end
  main_menu
end

#fill in data
def test
  #add politicians
  politician = Politician.new("Marco Rubio")
  politician.set_party("Republican")
  @politicians.push(politician)

  politician = Politician.new("Bernie Sanders")
  politician.set_party("Democrat")
  @politicians.push(politician)

  #random user  api
  url = 'https://randomuser.me/api/?results=100'
  resp = Net::HTTP.get_response(URI.parse(url))

  #parse json data
  json_data = JSON.parse(resp.body)

  #build voters array
  json_data["results"].each do |user|
    #build user name
    name = user["user"]["name"]["first"] + " " + user["user"]["name"]["last"]
    random_politics = rand(0..4)
    politics = @politics[random_politics]

    voter = Voter.new(name)
    voter.set_politics(politics)
    @voters << voter
  end

  #loop through voters to verify data, print name and politics
  # @voters.each do |voter|
  #   puts voter.pretty
  # end

  #run polling
  # poll = generate_poll
  # print_poll(poll)

end
#test data
test

#begin program
main_menu
