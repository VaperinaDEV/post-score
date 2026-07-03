import { withPluginApi } from "discourse/lib/plugin-api";
import icon from "discourse/helpers/d-icon";
import { concat } from "@ember/helper";
import DButton from "discourse/components/d-button";
import DTooltip from "float-kit/components/d-tooltip";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

function postScoreCount(api) {
  api.registerValueTransformer(
    "post-meta-data-infos",
    ({ value: metadata, context: { post, metaDataInfoKeys } }) => {

      const postScoreCalculation = Math.round(
        (
          post.reply_count * 5 +
          post.reaction_users_count * 15 +
          post.incoming_link_count * 5 +
          (post.bookmark_count ?? 0) * 2 +
          post.reads * 0.2
        ) * 10
      ) / 10;

      // Only add the component for specific posts
      if (post?.topic?.archetype !== "private_message" && postScoreCalculation > 1) {
        const PostScoreComponent = <template>
          <span class="post-score-count-tooltip">
            <DTooltip @interactive={{true}}>
              <:trigger>
                <div class="post-score-count-tooltip__trigger">
                  {{icon "chart-simple"}}
                  {{number postScoreCalculation noTitle="true"}}
                </div>
              </:trigger>
              <:content>
                <div class="post-score-count-tooltip__content">
                  <div class="post-score-count-tooltip__statistic">
                    {{concat (i18n (themePrefix "posts.post_score_tooltip")) ": " postScoreCalculation}}
                  </div>
                  <div class="post-score-count-tooltip__description">
                    {{i18n (themePrefix "posts.post_score_description_tooltip")}}
                  </div>
                  {{if settings.how_it_works_topic_available}}
                    <div class="post-score-count-tooltip__actions">
                      <DButton
                        class="btn-transparent btn-primary"
                        @label="discourse_ai.discobot_discoveries.tooltip.actions.info"
                        @href={{settings.how_it_works_topic}}
                      />
                    </div>
                  {{/if}}
                </div>
              </:content>
            </DTooltip>
          </span>
        </template>;

        metadata.add(
          "post-view-count-key",
          PostScoreComponent,
          {
            after: metaDataInfoKeys.DATE,
          }
        );
      }
    }
  );
}

export default {
  name: "post-score-count",
  initialize() {
    withPluginApi("0.8.7", (api) => {
      postScoreCount(api);
    });
  }
};
