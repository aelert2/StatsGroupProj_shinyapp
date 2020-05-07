Conclusion
==========

After wrangling, cleaning, exploring, modeling, and analyzing, we taken
a journey with this NFL play-by-play, weather, and betting data. Now we
will summarize our results. <br> <br>

Thesis
------

**2-point conversion attempts are more likely to be successful if they
are run plays and if the team with possession has ran the ball
successfully in the game up until the point of the 2-point conversion
attempt.** <br> <br> After creating our logistic model (Model 1), our
significant predictors were *total\_pass\_yards*, *num\_passes*, and
*play\_typerun* at a 0.001 alpha level. *play\_typerun* had the largest
coefficient at 0.5290071 meaning that for when a two-point conversion
attempt was a run play, the probility of success increased by 0.5290071.
Our model favors two-point conversion attempts where the team has a
large amount of passing yards but less passing attempts, meaning that
the offense is efficient when they do select to pass. It’s interesting
to us that *avg\_pass\_yards* was not significant as this predictor has
a direct relationship with both *total\_pass\_yards* and *num\_passes*.
<br> <br> In conclusion, the first part of our thesis was proved correct
as running the ball is a significant predictor of two-point conversion
success. The second part of our thesis focusing on the possession team’s
success in the game with running the ball up until the point of the
two-point conversion attempt did not prove to be significant in
determining the success of a two-point conversion attempt. We are
surprised by this discovery since it seems logical that a team’s success
with running the play would effect the team’s success with running the
ball on a two-point conversion attempt. <br> <br>

Future Work
-----------

If we could have controlled how the data was collected, we would be
interested to see more detailed play information about formations, run
gaps, offensive line, factors for the running back/quarterback, etc. to
get a more comprehensive overview of the offense that is being run. This
data would also allow us to provide a more detailed plan for offensive
coordinators looking to be as successful as possible on two-point
conversion attempt.
