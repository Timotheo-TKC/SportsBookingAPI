import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

actor SportsBookingAPI {
    type MatchId = Nat;
    type TeamId = Text;

    type Match = {
        id: MatchId;
        homeTeam: TeamId;
        awayTeam: TeamId;
        startTime: Int; // Unix timestamp
        sport: Text;
        odds: Odds;
        result: ?Result;
    };

    type Odds = {
        homeWin: Float;
        awayWin: Float;
        draw: Float;
    };

    type Result = {
        homeScore: Nat;
        awayScore: Nat;
        status: Text; // e.g., "Completed", "Cancelled", "Postponed"
    };

    private var nextMatchId : Nat = 1;
    private let matches = HashMap.HashMap<MatchId, Match>(100, Nat.equal, Hash.hash);

    // Add a new match
    public func addMatch(homeTeam: TeamId, awayTeam: TeamId, startTime: Int, sport: Text, odds: Odds) : async MatchId {
        let id = nextMatchId;
        nextMatchId += 1;

        let match : Match = {
            id = id;
            homeTeam = homeTeam;
            awayTeam = awayTeam;
            startTime = startTime;
            sport = sport;
            odds = odds;
            result = null;
        };

        matches.put(id, match);
        id
    };

    // Get match details
    public query func getMatch(id: MatchId) : async ?Match {
        matches.get(id)
    };

    // Update match odds
    public func updateOdds(id: MatchId, newOdds: Odds) : async Bool {
        switch (matches.get(id)) {
            case (null) { false };
            case (?match) {
                let updatedMatch : Match = {
                    id = match.id;
                    homeTeam = match.homeTeam;
                    awayTeam = match.awayTeam;
                    startTime = match.startTime;
                    sport = match.sport;
                    odds = newOdds;
                    result = match.result;
                };
                matches.put(id, updatedMatch);
                true
            };
        }
    };

    // Set match result
    public func setResult(id: MatchId, result: Result) : async Bool {
        switch (matches.get(id)) {
            case (null) { false };
            case (?match) {
                let updatedMatch : Match = {
                    id = match.id;
                    homeTeam = match.homeTeam;
                    awayTeam = match.awayTeam;
                    startTime = match.startTime;
                    sport = match.sport;
                    odds = match.odds;
                    result = ?result;
                };
                matches.put(id, updatedMatch);
                true
            };
        }
    };

    // List all matches
    public query func listMatches() : async [Match] {
        Iter.toArray(matches.vals())
    };

    // Get upcoming matches
    public query func getUpcomingMatches(currentTime: Int) : async [Match] {
        Array.filter<Match>(
            Iter.toArray(matches.vals()),
            func (match) { match.startTime > currentTime }
        )
    };

    // Get matches by sport
    public query func getMatchesBySport(sport: Text) : async [Match] {
        Array.filter<Match>(
            Iter.toArray(matches.vals()),
            func (match) { match.sport == sport }
        )
    };
}
