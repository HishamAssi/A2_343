import java.sql.*;
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
    		connection = DriveManager.getConection(url, username, password);
    		
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
    		return false;
    	}
    	
    	
        return true;
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
    public List<String> findSimilarPoliticians(int politicianId, float threshold) {
        // Implement this method!
        return null;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

