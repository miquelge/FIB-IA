#include<iostream>
#include<vector>
using namespace std;

string cities[] = {/* Oceania */ "Melbourne", "Sidney", "Wellington",

							/* Asia */ "Beijing", "Taiwan", "Tokio", "Nova_Dheli",

							/* Europe */ "Paris", "London", "Berlin", "Dublin",
							"Edinburgh", "Moscow",
							"Krakow", "Venice","Saint_Petersburg", "Istanbul",
							"Rome",

							/* South America */ "Caracas", "Rio_de_Janeiro",
							"La_Habana", "Medellin", "Cali",

							/* North America */ "Washington_DC", "New_York",

							/* Africa */

							/* Antarctica */ 
							};

string hotel1[] = {"Hotel", "Hostel", "Residence", "Apartments", "Resort", "Villa"};
string hotel2[] = {"Lollipop", "Paradise", "Single_Land", "Emperor", "Relax", "Chill", "Sky", "Arabiga", "NH", "Delphin"};

const int NUM_CITIES = (sizeof(cities)/sizeof(*cities));
const int NUM_HOTELS = NUM_CITIES;

int CITIES_TO_VISIT = 3;
int MIN_TRIP_DAYS = 5;
int MIN_TRIP_PRICE = 200;
int MAX_TRIP_PRICE = 400;
int VERSION = 0;

vector<vector<string> > probHotels(NUM_HOTELS);

void instances_generator(int seed) {
    MIN_TRIP_DAYS += (seed*3);
    MIN_TRIP_PRICE += (200*seed);
    MAX_TRIP_PRICE += (250*seed);
    CITIES_TO_VISIT += (seed*2);
	cout << "(define (problem tripProblem" << VERSION << seed <<")" << endl << "     (:domain trip-domain)" << endl;
	/* OBJECTS */
	cout << "(:objects" << endl;
		/* cities */
		for (string elm : cities)
			cout << elm << " ";
		cout << "- city" << endl;
		/* hotels */
		int hotelID = 0;
		string hotel;
		for (int i = 0; i < NUM_HOTELS; ++i) 
            for (int j = 0; j < 5 + seed*5; ++j) {
                hotel = hotel1[rand() % 5] + "_" + hotel2[rand() % 10] + "_" + to_string(hotelID++);
                probHotels[i].push_back(hotel);
                cout << hotel << " ";
            }
		
		cout << "- hotel" << endl;

	cout << ")" << endl; 
	/* INITIAL SITUATION */
	cout << "(:init" << endl;
		cout << "     (= (total-days) 0)" << endl;
		cout << "     (= (visited-cities) 0)" << endl;
		
		for (string city : cities) 
			cout << "     (= (stay " << city << ") 0)" << endl;

		if (VERSION > 0) {
			
			for (string city : cities) {
				cout << "     (= (minDaysCity " << city << ") " << (rand() % 2) + 1 << ")" << endl;
				cout << "     (= (maxDaysCity " << city << ") " << (rand() % 3) + 3 << ")" << endl; 
			}	

			if (VERSION == 2 or VERSION == 4) {
                cout << "     (= (total-interest) 0)" << endl;
				for (string city : cities) 
					cout << "     (= (cityInterest " << city << ") " << (rand() % 3) + 1 << ")" << endl;		 
            }
            
			if (VERSION == 3 or VERSION == 4) {
				cout << "     (= (total-price) 0)" << endl;
				cout << "     (= (minPriceTrip) " << MIN_TRIP_PRICE << ")" << endl;
				cout << "     (= (maxPriceTrip) " << MAX_TRIP_PRICE << ")" << endl;
				for (vector<string> hotels : probHotels)
                    for (string hotel : hotels)
                        cout << "     (= (hotelPrice " << hotel << ") " << rand() % (30 + 5*seed) + 10 << ")" << endl;		/* assuming price per night */				
			}
		}

		/* Flights */
		for (int i = 0; i < NUM_CITIES; ++i)
			for (int j = 0; j < NUM_CITIES; ++j) 
				if (i != j) {
					cout << "     (flight " << cities[i] << " " << cities[j] << ")" << endl;
					if (VERSION > 2) cout << "     (= (flightPrice " << cities[i] << " " << cities[j] << ") " << rand() % (30 + 5*seed) + 80 << ")" << endl;
				}

		/* Hotels distribution amongst Cities*/
		for (int i = 0; i < NUM_HOTELS; ++i)
            for (int j = 0; j < probHotels[i].size(); ++j)
                cout << "     (inCity " << probHotels[i][j] << " " << cities[i] << ")" << endl;
	cout << ")" << endl << endl;
	
	cout << "(:goal " << endl;	
		if (VERSION > 0) {
			cout << "(and (= (visited-cities) " << CITIES_TO_VISIT << ")" << endl;
			cout << "     (> (total-days) " << MIN_TRIP_DAYS << ")" << endl;

			if (VERSION > 2) {
				cout << "     (> (total-price) (minPriceTrip))" << endl;
				cout << "     (< (total-price) (maxPriceTrip))" << endl;
			}
			cout << ")" << endl;
		} else cout << "     (= (visited-cities) " << CITIES_TO_VISIT << ")" << endl; 
	cout << ")" << endl << endl;

	if (VERSION == 4) {
		cout << "(:metric" << endl << "     minimize (total-interest) " << endl << "     minimize (total-price))" << endl;
	} 
	else if (VERSION == 2) cout << "(:metric minimize (total-interest))" << endl;
	else if (VERSION == 3) cout << "(:metric minimize (total-price))" << endl;

	cout << endl << ")" << endl;

}

int main(int argc, char* argv[]) {
	
	if (argc != 3 or atoi(argv[1]) < 0 or atoi(argv[2]) < 0 or atoi(argv[2]) > 4) {
		cout << "USAGE: ./planifGenerator seed ext" << endl;
		cout << "where seed is a natural number and" << endl << "ext is the version of problem that is going to be generated [0-4]" << endl;
		return 0;
	}

	VERSION = atoi(argv[2]);

	cout << ";************** INSTANCES GENERATOR **************" << endl;
	cout << "; Planification project - Artificial Intelligence" << endl << endl << endl;
	
	instances_generator(atoi(argv[1]));
}
