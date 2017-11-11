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
        // Implement this method!
        return null;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianId, Float threshold) {
    	String queryMainPolitician = "SELECT id, description, comment FROM politician_president WHERE id = ?";
		try {
			PreparedStatement getMainPolitician = connection.prepareStatement(queryMainPolitician);
			getMainPolitician.setInt(1, politicianId);
			ResultSet politicianInfo = getMainPolitician.executeQuery();
			
			politicianInfo.next();
			String politicianDescription = politicianInfo.getString("description");
			String politicianComment = politicianInfo.getString("comment");
			String politicianAll = politicianDescription + " " + politicianComment;
			
			System.out.println(politicianAll);

			String queryOtherPoliticians = "SELECT id, description, comment FROM politician_president WHERE id != ?";
			PreparedStatement getOtherPoliticians = connection.prepareStatement(queryOtherPoliticians);
			getOtherPoliticians.setInt(1, politicianId);
			ResultSet otherPoliticianInfo = getOtherPoliticians.executeQuery();
			
			List<Integer> similarPoliticians = new ArrayList<Integer>();

	  
			while(otherPoliticianInfo.next()){
				System.out.println(otherPoliticianInfo.getInt("id"));
				String otherPoliticianDescription = otherPoliticianInfo.getString("description");
				String otherPoliticianComment = otherPoliticianInfo.getString("comment");
				String otherPoliticianAll = otherPoliticianDescription + " " + otherPoliticianComment;
				if (similarity(politicianDescription, otherPoliticianAll) > threshold){
					System.out.println("Truth be told.");
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
	//try {
		
		//Assignment2 test = new Assignment2();
		//test.connectDB("jdbc:postgresql://localhost:5432/csc343h-assihis1?currentSchema=parlgov",
				//"assihis1", "");

		//List<Integer> similarPoliticians = test.findSimilarPoliticians(9, (float) 0.01);
		//System.out.println(similarPoliticians);
	//}

	//catch (ClassNotFoundException se) {
		//System.err.println("SQL Exception." +
                   //"<Message>: " + se.getMessage());
	//}
        //System.out.println("Hello");
    }

}


