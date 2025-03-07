import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, NoticeBox, Section, Stack, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPortraitPrinter = (props) => {
  const { act, data } = useBackend();
  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 0);
  const [listIndex, setListIndex] = useLocalState('listIndex', 0);
  const { library, library_secure, library_private } = data;
  const TABS = [
    {
      name: 'Common Portraits',
      asset_prefix: 'library',
      list: library,
    },
    {
      name: 'Secure Portraits',
      asset_prefix: 'library_secure',
      list: library_secure,
    },
    {
      name: 'Private Portraits',
      asset_prefix: 'library_private',
      list: library_private,
    },
  ];
  const tab2list = TABS[tabIndex].list;
  const is_category_empty = tab2list[listIndex] !== 0;
  return (
    <NtosWindow title="Art Galaxy" width={400} height={406}>
      <NtosWindow.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fitted>
              <Tabs fluid textAlign="center">
                {TABS.map(
                  (tabObj, i) =>
                    !!tabObj.list && (
                      <Tabs.Tab
                        key={i}
                        selected={i === tabIndex}
                        onClick={() => {
                          setListIndex(0);
                          setTabIndex(i);
                        }}>
                        {tabObj.name}
                      </Tabs.Tab>
                    )
                )}
              </Tabs>
            </Section>
          </Stack.Item>
          {!!is_category_empty && (
            <Stack.Item grow={2}>
              <Section fill>
                <Stack height="100%" align="center" justify="center" direction="column">
                  <Stack.Item>
                    <Box
                      as="img"
                      src={resolveAsset(TABS[tabIndex].asset_prefix + '_' + tab2list[listIndex]['md5'])}
                      height="128px"
                      width="128px"
                      style={{
                        verticalAlign: 'middle',
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item className="Section__titleText">{tab2list[listIndex]['title']}</Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
          {!is_category_empty && (
            <Stack.Item grow={2}>
              <Section fill align="center">
                No Paintings detected in this category
              </Section>
            </Stack.Item>
          )}
          <Stack.Item>
            <Stack>
              <Stack.Item grow={3}>
                <Section height="100%">
                  <Stack justify="space-between">
                    <Stack.Item grow={1}>
                      <Button icon="angle-double-left" disabled={listIndex === 0} onClick={() => setListIndex(0)} />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button disabled={listIndex === 0} icon="chevron-left" onClick={() => setListIndex(listIndex - 1)} />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button
                        icon="check"
                        content="Print Portrait"
                        disabled={!is_category_empty}
                        onClick={() =>
                          act('select', {
                            tab: tabIndex + 1,
                            selected: listIndex + 1,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex === tab2list.length - 1}
                        onClick={() => setListIndex(listIndex + 1)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex === tab2list.length - 1}
                        onClick={() => setListIndex(tab2list.length - 1)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
            <Stack.Item mt={1} mb={-1}>
              <NoticeBox info>Printing a canvas costs 10 paper from the printer installed in your machine.</NoticeBox>
            </Stack.Item>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
