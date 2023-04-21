import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:timeago/timeago.dart' as timeago;

class PullRequestDetailsScreen extends StatelessWidget {
  final PullRequest? pullRequest;
  final String? pullRequestId;
  PullRequestDetailsScreen(
      {super.key, required this.pullRequest, required this.pullRequestId});

  final openPullRequestIcon = SvgPicture.asset(
    "assets/git-pull-request.svg",
    semanticsLabel: 'Pull Request Open Icon',
    fit: BoxFit.contain,
    colorFilter: const ColorFilter.mode(
        Color(0xFF42B954), BlendMode.srcIn), // Color(0xFF1D7F3A)
  );

  final closedPullRequestIcon = SvgPicture.asset(
    "assets/git-pull-request-closed.svg",
    semanticsLabel: 'Pull Request Closed Icon',
    fit: BoxFit.contain,
    colorFilter: const ColorFilter.mode(
        Color(0xFFCE2331), BlendMode.srcIn), //Color(0xFFF5504B)
  );

  final mergedPullRequestIcon = SvgPicture.asset("assets/git-merge.svg",
      fit: BoxFit.contain,
      semanticsLabel: 'Pull Request Merged Icon',
      colorFilter: const ColorFilter.mode(
          Color(0xFF8450DD), BlendMode.srcIn)); //Color(0xFFA571F5)

  final draftPullRequestIcon = SvgPicture.asset(
      "assets/git-pull-request-draft.svg",
      semanticsLabel: 'Pull Request Draft Icon',
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(
          Color(0xFF7E8590), BlendMode.srcIn)); //Color(0xFF656D76)

  @override
  Widget build(BuildContext context) {
    final ChipDetails chipDetails = pullRequest?.draft ?? false
        ? ChipDetails(
            label: 'Draft', icon: draftPullRequestIcon, color: Colors.grey)
        : pullRequest?.mergedAt != null
            ? ChipDetails(
                label: 'Merged',
                icon: mergedPullRequestIcon,
                color: Colors.purple)
            : pullRequest?.state == "closed"
                ? ChipDetails(
                    label: 'Closed',
                    icon: closedPullRequestIcon,
                    color: Colors.red)
                : ChipDetails(
                    label: 'Open',
                    icon: openPullRequestIcon,
                    color: Colors.green);
    final DateTime? createdAt = pullRequest?.createdAt;
    final DateTime? closedAt = pullRequest?.closedAt;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                spacing: 10.0,
                direction: Axis.horizontal,
                alignment: WrapAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: CachedNetworkImageProvider(pullRequest
                            ?.repoData["base"]["repo"]["owner"]["avatar_url"] ??
                        ""),
                  ),
                  Text(
                      "${pullRequest?.repoData['base']['repo']['owner']['login'] ?? ''} / ${pullRequest?.repoData['base']['repo']['name'] ?? ''}"),
                  Text("#${pullRequest?.number ?? ''}")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                pullRequest?.title ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Card(
                      color: chipDetails.color[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        child: Wrap(
                          spacing: 5.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(width: 16.0, child: chipDetails.icon),
                            Text(
                              chipDetails.label,
                              style: TextStyle(color: chipDetails.color[500]),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.cyan[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        child: Text(
                          pullRequest?.repoData["head"]["ref"] ?? "",
                          style: TextStyle(color: Colors.blue[500]),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_right_alt),
                    Card(
                      color: Colors.cyan[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text(
                          pullRequest?.repoData["base"]["ref"] ?? "",
                          style: TextStyle(color: Colors.blue[500]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white70,
                backgroundImage: CachedNetworkImageProvider(
                    pullRequest?.repoData["head"]["user"]["avatar_url"] ?? ""),
              ),
              title: RichText(
                maxLines: 1,
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          pullRequest?.repoData["head"]["user"]["login"] ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text:
                            " : ${createdAt != null ? timeago.format(createdAt, locale: 'en_short') : ''}",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 3.0),
                      child: Text(
                        pullRequest?.repoData["author_association"] ?? "",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ReadMore(bodyText: pullRequest?.repoData["body"] ?? ""),
            const Divider(),
            ...(pullRequest?.repoData['labels'] as List<dynamic>)
                .map(
                  (item) => ListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "added the ",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Card(
                              color: Color(int.parse(
                                  "0xff${item['color'] ?? '0xffffffff'}")),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  item["name"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: " label",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            (pullRequest?.repoData["labels"] as List<dynamic>).isNotEmpty
                ? const Divider()
                : Container(),
            ListTile(
              leading: chipDetails.icon,
              title: Text("Branch ${chipDetails.label}"),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${chipDetails.label} commit ",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    TextSpan(
                      text:
                          (pullRequest?.repoData['merge_commit_sha'] as String)
                              .substring(0, 7),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    pullRequest?.mergedAt != null
                        ? TextSpan(
                            text:
                                " into ${pullRequest?.repoData['base']['ref']} ${closedAt != null ? timeago.format(closedAt) : ''}",
                            style: Theme.of(context).textTheme.bodyLarge)
                        : pullRequest?.state == "closed"
                            ? TextSpan(
                                text: " as Completed",
                                style: Theme.of(context).textTheme.bodyLarge)
                            : TextSpan(
                                text: "Ready to be merged",
                                style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChipDetails {
  final String label;
  final SvgPicture icon;
  final ColorSwatch color;

  ChipDetails({required this.label, required this.icon, required this.color});
}

class ReadMore extends StatefulWidget {
  final String bodyText;

  const ReadMore({super.key, required this.bodyText});

  @override
  State<ReadMore> createState() => _ReadMoreState();
}

class _ReadMoreState extends State<ReadMore> {
  bool isReadMore = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: AutoSizeText(
        widget.bodyText,
        maxLines: isReadMore ? null : 5,
        style: Theme.of(context).textTheme.bodyLarge,
        overflowReplacement: Column(
          children: [
            Text(
              widget.bodyText,
              maxLines: 5,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.fade,
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isReadMore = true;
                });
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Read More'),
            ),
          ],
        ),
      ),
    );
  }
}
