import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.

public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
    	try {
    		connection = DriverManager.getConnection(url, username, password);
    		return true;
    		
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
    		return false;
    	}
    }

    @Override
    public boolean disconnectDB() {
    	try {
    		connection.close();
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
    		return false;
    	}
        // Implement this method!
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
	try {
	
	String queryCountryId = "SELECT id FROM country WHERE name = ?";
	
	PreparedStatement getCountryId = connection.prepareStatement(queryCountryId);
	getCountryId.setString(1,countryName);

	ResultSet CountryId = getCountryId.executeQuery();
	
	CountryId.next();
	int countryId = CountryId.getInt("id");
	
	
        String queryElectionSequence = "(SELECT cabinet.id as cabinet_id, election as election_id FROM " +
	"(SELECT e2.id as election, e1.id as next, e2.e_date as s_date, e1.e_date as end_date, e1.country_id as c_id, e1.e_type as e_type " + 
	"FROM election e1 JOIN election e2 ON e1.e_type = e2.e_type AND ((e2.id = e1.previous_parliament_election_id ) OR (e2.id = e1.previous_ep_election_id)) AND e1.country_id = e2.country_id WHERE e2.country_id = ?) AS election_cabinets " +
"JOIN cabinet ON election_cabinets.c_id = cabinet.country_id " +
"WHERE election_cabinets.s_date <= cabinet.start_date " + 
"AND election_cabinets.end_date >= cabinet.start_date) " +

/*"UNION " +

"(SELECT cabinet.id as cabinet_id, election.id as election_id " +
"FROM election JOIN cabinet ON election.country_id = cabinet.country_id AND election.country_id = ? " +
"WHERE ( " + 
"election.e_date IN " +
	"(SELECT max(e_date) as e_date " +
	"FROM election " + 
	"WHERE election.country_id = ? " +
	"GROUP BY (e_type))) " +
"AND (election.e_date <= cabinet.start_date)) " +*/

"ORDER BY election_id DESC;";

	PreparedStatement getElectionSequence = connection.prepareStatement(queryElectionSequence);
	getElectionSequence.setInt(1,countryId);
	//getElectionSequence.setInt(2,countryId);
	//getElectionSequence.setInt(3,countryId);

	ResultSet election_sequence = getElectionSequence.executeQuery();
	
	List<Integer> elections = new ArrayList<Integer>();
	List<Integer> cabinets = new ArrayList<Integer>();

	while(election_sequence.next()) {
		elections.add(election_sequence.getInt("election_id") );
		cabinets.add(election_sequence.getInt("cabinet_id"));
	}
	
        return new ElectionCabinetResult(elections, cabinets);
	} catch (SQLException se) {
			System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
    		return null;
	}
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianId, Float threshold) {
    	
		try {
			String queryMainPolitician = "SELECT id, description, comment FROM politician_president WHERE id = ?";
			PreparedStatement getMainPolitician = connection.prepareStatement(queryMainPolitician);
			getMainPolitician.setInt(1, politicianId);
			ResultSet politicianInfo = getMainPolitician.executeQuery();
			
			politicianInfo.next();
			String politicianDescription = politicianInfo.getString("description");
			String politicianComment = politicianInfo.getString("comment");
			String politicianAll = politicianDescription + " " + politicianComment;
			
			//System.out.println("politian all: " + politicianAll);

			String queryOtherPoliticians = "SELECT id, description, comment FROM politician_president WHERE id != ?";
			PreparedStatement getOtherPoliticians = connection.prepareStatement(queryOtherPoliticians);
			getOtherPoliticians.setInt(1, politicianId);
			ResultSet otherPoliticianInfo = getOtherPoliticians.executeQuery();
			
			List<Integer> similarPoliticians = new ArrayList<Integer>();

	  
			while(otherPoliticianInfo.next()){
				//System.out.println(otherPoliticianInfo.getInt("id"));
				String otherPoliticianDescription = otherPoliticianInfo.getString("description");
				String otherPoliticianComment = otherPoliticianInfo.getString("comment");
				String otherPoliticianAll = otherPoliticianDescription + " " + otherPoliticianComment;
				if (similarity(politicianDescription, otherPoliticianAll) > threshold){
					//System.out.println("Truth be told.");
					similarPoliticians.add(otherPoliticianInfo.getInt("id"));
				}
			}
			return similarPoliticians;
		}
		catch (SQLException se) {
			System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
    		return null;
		}
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.

	try {
		
		Assignment2 test = new Assignment2();
		test.connectDB("jdbc:postgresql://localhost:5432/csc343h-assihis1?currentSchema=parlgov",
				"assihis1", "");

		List<Integer> similarPoliticians = test.findSimilarPoliticians(148, (float) 0.01);
		ElectionCabinetResult election_result = test.electionSequence("Germany");
		System.out.println(election_result.elections  + "size: " + election_result.elections.size());
		System.out.println(election_result.cabinets);
		System.out.println(similarPoliticians);
	}

	catch (ClassNotFoundException se) {
		System.err.println("SQL Exception." +
                   "<Message>: " + se.getMessage());
	}
    
    }

}


