import { SignInPage } from '@backstage/core-components';
import { githubAuthApiRef } from '@backstage/core-plugin-api';
import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';

export const githubSignInModule = createFrontendModule({
  pluginId: 'app',
  extensions: [
    SignInPageBlueprint.make({
      params: {
        loader: async () => props => (
          <SignInPage
            {...props}
            auto
            provider={{
              id: 'github-auth-provider',
              title: 'GitHub',
              message: 'Sign in using your Oz-hubs GitHub account',
              apiRef: githubAuthApiRef,
            }}
          />
        ),
      },
    }),
  ],
});
