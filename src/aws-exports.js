// src/aws-exports.js
const awsmobile = {
    aws_project_region: "us-west-2",
    aws_cognito_identity_pool_id: "", // Optional if not using Identity Pool
    aws_cognito_region: "us-west-2",
    aws_user_pools_id: "us-west-2_atOwvbO12",
    aws_user_pools_web_client_id: "4vq96f8njdfqgr2qaq75hokuak",
    oauth: {},
    aws_appsync_graphqlEndpoint: "https://<YOUR_APPSYNC_API_ID>.appsync-api.us-west-2.amazonaws.com/graphql", // Replace if using AppSync
    aws_appsync_region: "us-west-2",
    aws_appsync_authenticationType: "AMAZON_COGNITO_USER_POOLS",
};

export default awsmobile;

