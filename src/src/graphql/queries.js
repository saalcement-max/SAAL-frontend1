// src/graphql/queries.js
export const listItems = /* GraphQL */ `
  query ListItems {
    listItems {
      items {
        id
        name
      }
    }
  }
`;

