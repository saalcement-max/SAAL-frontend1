export const listItems = /* GraphQL */ `
  query ListItems {
    listItems {
      items {
        id
        name
        createdAt
        updatedAt
      }
    }
  }
`;

