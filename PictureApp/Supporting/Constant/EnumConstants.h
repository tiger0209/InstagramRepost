//
//  EnumConstants.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/19/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

typedef enum {
    SelectionUnfollowers,
    SelectionNewFollowers,
    SelectionUnfollowed,
    SelectionFans,
    SelectionMutualFriends,
    SelectionNonFollowers,
    SelectionFollowers,
    SelectionFollowing,
    SelectionMostLikes,
    SelectionLeastLikes,
    SelectionMostComments,
    SelectionLeastComments,
    SelectionMostCommentsAndLikes,
    SelectionLeastCommentsAndLikes,
    SelectionFavoriteUsers,
    SelectionNewestUsers,
    SelectionOldestUsers,
    SelectionLikedDoNotFollow,
    SelectionSecretAdmirers,
    SelectionNearby,
    SelectionFarAway
} Selection;

typedef enum {
    RelationshipNotLoaded,
    RelationshipSelf,
    RelationshipFollowing,
    RelationshipNotFollowing,
    RelationshipNotFollowingPrivate,
    RelationshipRequested,
    RelationshipUnknown
} Relationship;

typedef enum {
    UpdateBegan,
    UpdateEnded,
    UpdateFailed
} Update;



